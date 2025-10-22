import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http/io_client.dart';
import 'package:pointycastle/api.dart' as api;
import 'package:pointycastle/asymmetric/api.dart';
import "crypto.dart";
import 'package:path_provider/path_provider.dart';

void main() => runApp(const FabricFlutter());
HttpClient client = HttpClient()
  ..badCertificateCallback =
      ((X509Certificate cert, String host, int port) => true);
IOClient ioClient = IOClient(client);

class FabricFlutter extends StatelessWidget {
  const FabricFlutter({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'fabric_client_flutter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(title: const Text('Hyperledger Fabric Flutter Client')),
        body: const BodyWidget(),
      ),
    );
  }
}

class BodyWidget extends StatefulWidget {
  const BodyWidget({super.key});

  @override
  BodyWidgetState createState() {
    return BodyWidgetState();
  }
}

class BodyWidgetState extends State<BodyWidget> {
  String? clipboard = '';
  late api.AsymmetricKeyPair<api.PublicKey, api.PrivateKey> keypair;
  late RSAPrivateKey privateKey;
  bool ready = false;
  Uint8List? unsignedProposal = Uint8List(0);
  String? sig = '';
  String? csr = '';
  String? certPem = '';
  Object? proposalResponse;

  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  final channelController = TextEditingController();
  final certificateController = TextEditingController();
  final addressController = TextEditingController();
  final nameController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    channelController.dispose();
    certificateController.dispose();
    addressController.dispose();
    nameController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(10.0),
      shrinkWrap: true,
      children: <Widget>[
              Align(
                child: SelectableText(clipboard!)
              ),
              ButtonTheme(
                minWidth: 400.0,
                height: 40.0,
                textTheme: ButtonTextTheme.primary,
                child: ElevatedButton(
                  child: const Text('Generate Key Pair'),
                  onPressed: () async {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        });
                    await _makeKeypairRequest();
                    if (!context.mounted) return;
                    Navigator.of(context).pop();
                  },
                ),
              ),
              Visibility(
                visible: ready,
                child: ButtonTheme(
                  minWidth: 400.0,
                  height: 40.0,
                  textTheme: ButtonTextTheme.primary,
                  child: ElevatedButton(
                    child: const Text('Get Private Key'),
                    onPressed: () {
                      _makePrivateKeyRequest();
                    },
                  ),
                ),
              ),
              Visibility(
                visible: ready,
                child: ButtonTheme(
                  minWidth: 400.0,
                  height: 40.0,
                  textTheme: ButtonTextTheme.primary,
                  child: ElevatedButton(
                    child: const Text('Get Public Key'),
                    onPressed: () {
                      _makePublicKeyRequest();
                    },
                  ),
                ),
              ),
              Visibility(
                visible: ready,
                child: TextField(
                  controller: channelController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Channel ID',
                    contentPadding: EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 8.0),
                  ),
                ),
              ),
              Visibility(
                visible: ready,
                child: ButtonTheme(
                  minWidth: 400.0,
                  height: 40.0,
                  textTheme: ButtonTextTheme.primary,
                  child: ElevatedButton(
                    child: const Text('Setup Fabric Channel'),
                    onPressed: () {
                      _makeSetupChannelRequest(channelController.text);
                    },
                  ),
                ),
              ),
              Visibility(
                visible: ready,
                child: TextField(
                  controller: certificateController,
                  decoration: const InputDecoration(
                    labelText: 'Certificate Path',
                    contentPadding: EdgeInsets.symmetric(
                        vertical: 4.0, horizontal: 4.0),
                  ),
                ),
              ),
              Visibility(
                visible: ready,
                child: TextField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: 'Listen Address',
                    contentPadding: EdgeInsets.symmetric(
                        vertical: 4.0, horizontal: 4.0),
                  ),
                ),
              ),
              Visibility(
                visible: ready,
                child: TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    contentPadding: EdgeInsets.symmetric(
                        vertical: 4.0, horizontal: 4.0),
                  ),
                ),
              ),
              Visibility(
                visible: ready,
                child: ButtonTheme(
                  minWidth: 400.0,
                  height: 40.0,
                  textTheme: ButtonTextTheme.primary,
                  child: ElevatedButton(
                    child: const Text('Setup Fabric Peer / Orderer'),
                    onPressed: () {
                      _showAlert();
                    },
                  ),
                ),
              ),
              Visibility(
                visible: ready,
                child: ButtonTheme(
                  minWidth: 400.0,
                  height: 40.0,
                  textTheme: ButtonTextTheme.primary,
                  child: ElevatedButton(
                    child: const Text('Generate Certificate Signing Request'),
                    onPressed: () {
                      _makeCSRGeneration();
                    },
                  ),
                ),
              ),
              Visibility(
                visible: ready,
                child: ButtonTheme(
                  minWidth: 400.0,
                  height: 40.0,
                  textTheme: ButtonTextTheme.primary,
                  child: ElevatedButton(
                    child: const Text('Request Certificate from Fabric CA'),
                    onPressed: () {
                      _makeCertificateGenerationRequest();
                    },
                  ),
                ),
              ),
              Visibility(
                visible: ready,
                child: ButtonTheme(
                  minWidth: 400.0,
                  height: 40.0,
                  textTheme: ButtonTextTheme.primary,
                  child: ElevatedButton(
                    child: const Text('Request Unsigned Proposal Generation'),
                    onPressed: () {
                      _makeUnsignedProposalGenerationRequest();
                    },
                  ),
                ),
              ),
              Visibility(
                visible: ready,
                child: ButtonTheme(
                  minWidth: 400.0,
                  height: 40.0,
                  textTheme: ButtonTextTheme.primary,
                  child: ElevatedButton(
                    child: const Text('Sign Proposal'),
                    onPressed: () {
                      _makeSigningProposal();
                    },
                  ),
                ),
              ),
              Visibility(
                visible: ready,
                child: ButtonTheme(
                  minWidth: 400.0,
                  height: 40.0,
                  textTheme: ButtonTextTheme.primary,
                  child: ElevatedButton(
                    child: const Text('Send Signed Proposal'),
                    onPressed: () {
                      _makeProposalSendingRequest();
                    },
                  ),
                ),
              ),
            ],
          );
  }

  Future<void> _showAlert() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Choose peer or orderer for this setup?'),
              ],
            ),
          ),
          actions: <Widget>[
             TextButton(
              child: const Text("Close"),
              onPressed: () {
                Navigator.of(context).pop(); // Closes the dialog
              },
            ),
            TextButton(
              child: const Text('Peer'),
              onPressed: () {
                _makeSetupPeerRequest(certificateController.text,
                    addressController.text, nameController.text);
              },
            ),
            TextButton(
              child: const Text('Orderer'),
              onPressed: () {
                _makeSetupOrdererRequest(certificateController.text,
                    addressController.text, nameController.text);
              },
            ),
          ],
        );
      },
    );
  }

  _writeToFile(String encodedString, String filename) async {
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    final file = File('$tempPath/$filename');
    await file.writeAsString(encodedString);
    return file;
  }

  _upload(File file, String url) async {
    String filebody = file.readAsStringSync();
    String filename = file.path.split("/").last;
    Response res =
        await ioClient.post(Uri.parse(url), body: {"content": filebody, "name": filename});
    return res;
  }

  _makeKeypairRequest() async {
    var pair = await makeGenerationRequest();
    setState(() {
      keypair = pair;
      ready = true;
    });
  }

  _makeCSRGeneration() async {
    setState(() {
      csr = generateCSR(keypair.privateKey as RSAPrivateKey, keypair.publicKey as RSAPublicKey);
      clipboard = csr;
    });
  }

  _makeSetupChannelRequest(String channelId) async {
    Response response = await ioClient.get(Uri.parse(_requestChannelSetup(channelId)));
    setState(() {
      clipboard = response.body;
    });
  }

  _makeSetupPeerRequest(String cert, String address, String name) async {
    Response response =
        await ioClient.get(Uri.parse(_requestPeerSetup(cert, address, name)));
    setState(() {
      clipboard = response.body;
    });
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  _makeSetupOrdererRequest(String cert, String address, String name) async {
    Response response =
        await ioClient.get(Uri.parse(_requestOrdererSetup(cert, address, name)));
    setState(() {
      clipboard = response.body;
    });
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  _makePrivateKeyRequest() async {
    var privateKeyPem = encodePrivateKeyToPem(keypair.privateKey as RSAPrivateKey);
    setState(() {
      clipboard = privateKeyPem;
      privateKey = keypair.privateKey as RSAPrivateKey;
    });
  }

  _makePublicKeyRequest() async {
    var publicKeyPem = encodePublicKeyToPem(keypair.publicKey as RSAPublicKey);
    setState(() {
      clipboard = publicKeyPem;
    });
  }

  _makeUnsignedProposalGenerationRequest() async {
    Response response = await ioClient
        .post(Uri.parse(_requestUnsignedProposalGeneration()), body: {"cert": certPem});
    setState(() {
      unsignedProposal = response.bodyBytes;
      clipboard = response.body;
    });
  }

  _makeSigningProposal() async {
    String signature = sign(unsignedProposal!, privateKey);
    setState(() {
      sig = signature;
      clipboard = sig;
    });
  }

  _makeProposalSendingRequest() async {
    File file = await _writeToFile(sig!, 'signature.txt');
    Response response = await _upload(file, _requestProposalSending());
    setState(() {
      proposalResponse = response.body;
      clipboard = proposalResponse as String?;
    });
  }

  _makeCertificateGenerationRequest() async {
    File file = await _writeToFile(csr!, 'cert.csr');
    Response response = await _upload(file, _requestCertificate());
    setState(() {
      certPem = response.body;
      clipboard = certPem;
    });
  }

  String _requestChannelSetup(String channelId) {
      return '${_getBaseUri()}/setupChannel?id=$channelId';
  }

  String _requestPeerSetup(String cert, String address, String name) {
      return '${_getBaseUri()}/setupPeer?cert=$cert&address=$address&name=$name';
  }

  String _requestOrdererSetup(String cert, String address, String name) {
      return '${_getBaseUri()}/setupOrderer?cert=$cert&address=$address&name=$name';
  }

  String _requestProposalSending() {
      return '${_getBaseUri()}/sendSignedProposal';
  }

  String _requestUnsignedProposalGeneration() {
      return '${_getBaseUri()}/generateUnsignedProposal';
  }

  String _requestCertificate() {
      return '${_getBaseUri()}/requestCertificate';
  }

  String _getBaseUri() {
    if (Platform.isAndroid) {
      // for Android emulator
      return 'https://10.0.2.2:8081';
    } else {
      // for iOS simulator
      return 'https://localhost:8081';
    }
  }
}
