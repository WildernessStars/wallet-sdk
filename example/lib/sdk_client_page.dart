import 'package:flutter/material.dart';
import 'package:web3_smartwatch_sdk/web3_smartwatch_sdk.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WalletSdkClientPage extends StatefulWidget {
  const WalletSdkClientPage({super.key});

  @override
  State<WalletSdkClientPage> createState() => _WalletSdkClientPageState();
}

class _WalletSdkClientPageState extends State<WalletSdkClientPage> {
  late BridgeClient bridgeClient;
  late Web3SmartwatchSdk sdk;
  late InAppWebViewController webViewController;
  bool _bridgeReady = false;

  @override
  void initState() {
    super.initState();
    var ANKR_API_KEY='';
    sdk = Web3SmartwatchSdk(
      rpcConfig: {
        '0xaa36a7': 'https://rpc.ankr.com/eth_sepolia/$ANKR_API_KEY',
      },
    );
  }
  Future<void> _initBridge() async {
    var wallet = await sdk.getWallet();
    if (wallet == null) {
      await sdk.createWallet(); 
    }

    print("初始化bridge");
    bridgeClient = BridgeClient(
      webViewController: webViewController,
      provider: await sdk.getProvider(),
      debug: true,
    );
    setState(() {
      _bridgeReady = true;
    });
  }

  void _testConnect() async {
    final result = await bridgeClient.debugCall(BridgeAction.getAccounts, []);
    print("连接钱包结果: $result");
  }
  void _testGetBalance() async {
    final result = await bridgeClient.debugCall(BridgeAction.getBalance, []);
    print("获取余额结果: $result");
  }
  void _testSign() async {
    final result = await bridgeClient.debugCall(BridgeAction.sign, 'hello wallet');
    print("签名消息结果: $result");
  }
  void _testSend() async {
    var addr = '0xd0C8fbfE821D8D49f5EE37340c62563a2A198Cc1';
    final result = await bridgeClient.debugCall(BridgeAction.sendMessage, {'to': addr, 'data': '0x68656c6c6f2077616c6c6574'});
    print("发送消息结果: $result");
  }
  void _testChainId() async {
    final result = await bridgeClient.debugCall(BridgeAction.getChainId, []);
    print("获取链ID结果: $result");
  }
  void _testSendTransaction() async {
    var addr = '0xC53132eF503aDE3a1cD163a975b4E83d79F94145';
    final result = await bridgeClient.debugCall(BridgeAction.send, {'to': addr, 'value': '10000000000000',  'gas': '3000000'});
    print("发送交易结果: $result");
  }
  void _testSetter() async {
    var addr = '0xC53132eF503aDE3a1cD163a975b4E83d79F94145';
    var contractAddr = '0xd0C8fbfE821D8D49f5EE37340c62563a2A198Cc1';
    final result = await bridgeClient.debugCall(BridgeAction.setter, {
      'function': 'mint(address, uint256, uint256, bytes)', 
      'params': [
        addr,
        '1',
        '10',
        '0x'
      ],
      'to': contractAddr,
    });
    print("Setter结果: $result");
  }
  void _testGetter() async {
    var contractAddr = '0xd0C8fbfE821D8D49f5EE37340c62563a2A198Cc1';
    final result = await bridgeClient.debugCall(BridgeAction.getter, {
      'to': contractAddr,
      'function': 'batchSize()',
      'params': [],
    });
    print("Getter结果: $result");
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("BridgeClient 测试页")),
      body: Column(
        children: [
          SizedBox(
            height: 300,
            child: InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri("about:blank")),
              onWebViewCreated: (controller) async {
                webViewController = controller;
                await _initBridge();
                print("webView初始化完成");
              },
            ),
          ),
          ElevatedButton(
            onPressed: _bridgeReady ? _testConnect : null,
            child: const Text("Connect"),
          ),
          ElevatedButton(
            onPressed: _bridgeReady ? _testGetBalance : null,
            child: const Text("Get Balance"),
          ),
          ElevatedButton(
            onPressed: _bridgeReady ? _testSign : null,
            child: const Text("Sign Message"),
          ),
          ElevatedButton(
            onPressed: _bridgeReady ? _testSend : null,
            child: const Text("Send Message"),
          ),
          ElevatedButton(
            onPressed: _bridgeReady ? _testGetter : null,
            child: const Text("Getter"),
          ),
          ElevatedButton(
            onPressed: _bridgeReady ? _testSetter : null,
            child: const Text("Setter"),
          ),
          ElevatedButton(
            onPressed: _bridgeReady ? _testSendTransaction : null,
            child: const Text("Send Transaction"),
          ),
          ElevatedButton(
            onPressed: _bridgeReady ? _testChainId : null,
            child: const Text("ChainId"),
          ),
        ],
      ),
    );
  }
}
