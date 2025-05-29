import 'dart:convert';
import 'dart:typed_data';
import 'package:web3_smartwatch_sdk/web3_smartwatch_sdk.dart' show WalletImpl;
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';
import 'dart:async';
import 'package:web3dart/crypto.dart' show hexToBytes, bytesToHex;

/// 连接信息类，用于存储账户地址和链ID
class ConnectionInfo {
  final String account;
  final String chainId;

  ConnectionInfo({required this.account, required this.chainId});

  factory ConnectionInfo.fromJson(Map<String, dynamic> json) {
    return ConnectionInfo(
      account: json['account'],
      chainId: json['chainId'],
    );
  }
}

/// RPC管理器类，用于管理不同链的RPC端点和Web3Client实例
class RPCManager {
  static final RPCManager _instance = RPCManager._internal();
  factory RPCManager() => _instance;
  RPCManager._internal();

  /// 存储不同链ID对应的RPC端点
  final Map<String, String> _rpcEndpoints = {};

  /// 缓存已创建的Web3Client实例，避免重复创建
  final Map<String, Web3Client> _providerCache = {};

  /// 初始化RPC配置
  void initialize(Map<String, String> config) {
    _rpcEndpoints.clear();
    _rpcEndpoints.addAll(config);
    _providerCache.clear();
  }

  /// 添加或更新RPC配置
  void updateRpcConfig(String chainId, String url) {
    _rpcEndpoints[chainId] = url;
    _providerCache.remove(chainId); 
  }

  /// 获取指定链的Web3Client实例
  Web3Client getProvider(String chainId, {bool forceNew = false}) {
    if (!_rpcEndpoints.containsKey(chainId)) {
      throw ArgumentError('Unsupported chainId: $chainId');
    }

    // 使用缓存避免重复创建
    if (!forceNew && _providerCache.containsKey(chainId)) {
      return _providerCache[chainId]!;
    }

    final client = Web3Client(
      _rpcEndpoints[chainId]!,
      http.Client(),
    );
    return _providerCache[chainId] = client;
  }
}

/// Transaction类的JSON序列化扩展
extension TransactionFromJson on Transaction {
  /// 从JSON创建Transaction实例
  static Transaction fromJson(Map<String, dynamic> json) {
    EthereumAddress.fromHex(json['to']);
    EtherAmount.inWei(BigInt.parse(_stripHexPrefix(json['value'])));
    EtherAmount.inWei(BigInt.parse(_stripHexPrefix(json['gasPrice'])));

    return Transaction(
      from: json['from'] != null ? EthereumAddress.fromHex(json['from']) : null,
      to: json['to'] != null ? EthereumAddress.fromHex(json['to']) : null,
      value: json['value'] != null
          ? EtherAmount.inWei(BigInt.parse(_stripHexPrefix(json['value'])))
          : null,
      gasPrice: json['gasPrice'] != null
          ? EtherAmount.inWei(BigInt.parse(_stripHexPrefix(json['gasPrice'])))
          : null,
      maxGas: json['gas'] != null
          ? int.tryParse(_stripHexPrefix(json['gas']))
          : null,
      data: json['data'] != null ? hexToBytes(json['data']) : Uint8List(0),
      nonce: json['nonce'] != null
          ? int.tryParse(_stripHexPrefix(json['nonce']))
          : null,
    );
  }
}

/// Transaction类的JSON反序列化扩展
extension TransactionSerialization on Transaction {
  /// 将Transaction实例转换为JSON
  Map<String, dynamic> toJson() {
    return {
      if (from != null) 'from': from!.hex,
      if (to != null) 'to': to!.hex,
      if (value != null) 'value': '0x${value!.getInWei.toRadixString(16)}',
      if (gasPrice != null)
        'gasPrice': '0x${gasPrice!.getInWei.toRadixString(16)}',
      if (maxGas != null) 'gas': '0x${maxGas!.toRadixString(16)}',
      if (data != null && data!.isNotEmpty)
        'data': '0x${bytesToHex(data!, include0x: false)}',
      if (nonce != null) 'nonce': '0x${nonce!.toRadixString(16)}',
    };
  }
}

/// 移除十六进制字符串的0x前缀
String _stripHexPrefix(String hex) {
  return hex.startsWith('0x') ? hex.substring(2) : hex;
}

/// EIP-1193标准的Provider实现类
class EIP1193Provider {
  WalletImpl? _wallet;
  String _chainId = '0xaa36a7';

  final Web3Client Function(String chainId) _providerResolver;
  /// 连接请求事件流控制器
  final _connectionRequestController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get onConnectionRequest => _connectionRequestController.stream;

  /// 设置钱包实例
  setWallet(WalletImpl wallet) {
    _wallet = wallet;
  }

  /// 切换链
  Future<void> switchChain(String chainId) async {
    _chainId = chainId;
  }

  /// 获取当前链ID
  Future<String> getChainId() async {
    return _chainId;
  }

  EIP1193Provider({required Web3Client Function(String chainId) providerResolver})
      : _providerResolver = providerResolver;

  /// 连接到钱包
  Future<List<dynamic>> connect({String chainId = '0x1'}) async {
    // 发送连接请求事件
    _connectionRequestController.add({
      'type': 'connection_request',
      'chainId': chainId,
    });

    // 等待用户确认（应由UI层处理）
    if (_wallet != null) {
      return [_wallet!.address, _chainId];
    }
    return [];
  }

  /// 处理连接响应
  void handleConnectionResponse(bool accepted) {
    if (accepted && _wallet != null) {
      _connectionRequestController.add({
        'type': 'connection_accepted',
        'account': _wallet!.address,
        'chainId': _chainId,
      });
    } else {
      _connectionRequestController.add({
        'type': 'connection_rejected',
      });
    }
  }

  /// 发送交易
  Future<String> sendTransaction(Map<String, dynamic> tx) async {
    if (_wallet == null) throw Exception("Wallet not initialized");
    final provider = _providerResolver(_chainId);
    // 获取nonce
    final nonce = await provider.getTransactionCount(EthereumAddress.fromHex(_wallet!.address), atBlock: BlockNum.pending());
    tx['nonce'] = nonce.toString();
    // 如果没有设置gasPrice，则获取当前网络的gasPrice
    if (tx['gasPrice'] == null) {
      final gasPrice = await provider.getGasPrice();
      tx['gasPrice'] = gasPrice.getInWei.toString();
    }
    final transaction = TransactionFromJson.fromJson(tx);
    final signedTx = await _wallet!.signTransaction(transaction, _chainId);
    return provider.sendRawTransaction(signedTx);
  }

  /// 签名消息
  Future<String> signMessage(String message) async {
    if (_wallet == null) throw Exception("Wallet not initialized");
    return _wallet!.signMessage(message);
  }

  /// 获取账户余额
  Future<String> getBalance() async {
    if (_wallet == null) throw Exception("Wallet not initialized");
    final address = _wallet!.address;
    final provider = _providerResolver(_chainId); 
    final balance = await provider.getBalance(EthereumAddress.fromHex(address));
    return balance.getInWei.toString(); 
  }

  /// 调用合约只读方法
  Future<String> call(Map<String, dynamic> call) async {
    return callContractFunction(
      contractAddress: call['to'],
      data: call['data'],
      send: false,
    );
  }

  /// 发送合约交易
  Future<String> sendMessage(Map<String, dynamic> call) async {
    return callContractFunction(
      contractAddress: call['to'],
      data: call['data'],
      send: true,
    );
  }

  /// 调用合约getter方法
  Future<String> callGetter(Map<String, dynamic> call) async {
    final data = encodeFunctionCall(
      functionSignature: call['function'],
      params: call['params'],
    );

    return callContractFunction(
      contractAddress: call['to'],
      data: data,
      abi: call['abi'],
      send: false,
    );
  }

  /// 调用合约setter方法
  Future<String> callSetter(Map<String, dynamic> call) async {
    final data = encodeFunctionCall(
      functionSignature: call['function'],
      params: call['params'],
    );
    final txHash = await callContractFunction(
      contractAddress: call['to'],
      data: data,
      send: true,
      value: call['value'],
    );
    final provider = _providerResolver(_chainId);
    final receipt = await waitForReceipt(provider, txHash);
    if (receipt != null && receipt.status == true) {
      print("transaction success");
      for (final log in receipt.logs) {
        print(log); 
      }
    } else {
      print("transaction failed");
    }
    return txHash;
  }

  /// 等待交易收据
  Future<TransactionReceipt?> waitForReceipt(Web3Client client, String txHash) async {
    while (true) {
      final receipt = await client.getTransactionReceipt(txHash);
      if (receipt != null) return receipt;
      await Future.delayed(Duration(seconds: 4));
    }
  }

  /// 编码函数调用
  String encodeFunctionCall({
    required String functionSignature,
    List<dynamic> params = const [],
  }) {
    final regex = RegExp(r'(\w+)\((.*)\)');
    final match = regex.firstMatch(functionSignature);

    if (match == null) {
      throw ArgumentError('Invalid function signature: $functionSignature');
    }

    final name = match.group(1)!;
    final paramTypes = match.group(2)!
        .split(',')
        .where((t) => t.trim().isNotEmpty)
        .map((t) => FunctionParameter<dynamic>('', parseAbiType(t.trim())))
        .toList();

    final function = ContractFunction(name, paramTypes);
    final convertedParams = <dynamic>[];
    // 转换参数类型
    for (int i = 0; i < params.length; i++) {
      final type = paramTypes[i].type;
      final value = params[i];
      if (type is AddressType && value is String) {
        convertedParams.add(EthereumAddress.fromHex(value));
      } else if (type is UintType && value is int) {
        convertedParams.add(BigInt.from(value));
      } else if (type is UintType && value is String) {
        convertedParams.add(BigInt.parse(value));
      } else if (type is DynamicBytes && value is String) {
        convertedParams.add(hexToBytes(value));
      } else {
        convertedParams.add(value); 
      }
    }
    final encoded = function.encodeCall(convertedParams);
    return bytesToHex(encoded, include0x: true);
  }

  /// 调用合约函数
  Future<String> callContractFunction({
    required String contractAddress,
    required String data,
    bool send = false,
    BigInt? value,
    BigInt? gasLimit,
    BigInt? gasPrice,
    String? abi,
  }) async {
    final EthereumAddress to = EthereumAddress.fromHex(contractAddress);
    final provider = _providerResolver(_chainId);
    if (send) {
      if (_wallet == null) throw Exception("Wallet not initialized");
      // 获取nonce和gasPrice
      final nonce = await provider.getTransactionCount(EthereumAddress.fromHex(_wallet!.address), atBlock: BlockNum.pending());
      final gasPrice = await provider.getGasPrice();
      final tx = Transaction(
        nonce: nonce,
        to: to,
        data: hexToBytes(data),
        value: value != null ? EtherAmount.inWei(value) : EtherAmount.zero(),
        maxGas: gasLimit?.toInt() ?? 3000000,
        gasPrice: gasPrice,
      );

      final signedTx = await _wallet!.signTransaction(tx, _chainId);
      return await provider.sendRawTransaction(signedTx);
    } else {
      final result = await provider.callRaw(
        sender: EthereumAddress.fromHex(_wallet!.address),
        contract: to,
        data: hexToBytes(data),
      );
      return result;
    }
  }

  /// 清理资源
  void dispose() {
    _connectionRequestController.close();
  }
}
