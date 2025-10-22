// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:fabric_client_flutter/main.dart';

void main() {
  testWidgets('initial widgets test', (WidgetTester tester) async {
    // build our app and trigger a frame.
    await tester.pumpWidget(const FabricFlutter());

    var titleFinder = find.text('Hyperledger Fabric Flutter Client');
    var generateKeyPairFinder = find.text('Generate Key Pair');
    var getPrivKeyFinder = find.text('Get Private Key');
    var getPubKeyFinder = find.text('Get Public Key');
    var channelIdFinder = find.text('Channel ID');
    var setupFabricChannelFinder = find.text('Setup Fabric Channel');
    var certPathFinder = find.text('Certificate Path');
    var listenAddrFinder = find.text('Listen Address');
    var nameFinder = find.text('Name');
    var setupFabricPeerOrdererFinder = find.text('Setup Fabric Peer / Orderer');
    var genCertSignReqFinder = find.text('Generate Certificate Signing Request');
    var reqCertFabricCaFinder = find.text('Request Certificate from Fabric CA');
    var reqUnsignedPropGenFinder = find.text('Request Unsigned Proposal Generation');
    var signProposalFinder = find.text('Sign Proposal');
    var sendSignedPropFinder = find.text('Send Signed Proposal');

    // verify that initial widgets are ready
    expect(titleFinder, findsOneWidget);
    expect(generateKeyPairFinder, findsOneWidget);

    // uninitialized widgets
    expect(getPrivKeyFinder, findsNothing);
    expect(getPubKeyFinder, findsNothing);
    expect(channelIdFinder, findsNothing);
    expect(setupFabricChannelFinder, findsNothing);
    expect(certPathFinder, findsNothing);
    expect(listenAddrFinder, findsNothing);
    expect(nameFinder, findsNothing);
    expect(setupFabricPeerOrdererFinder, findsNothing);
    expect(genCertSignReqFinder, findsNothing);
    expect(reqCertFabricCaFinder, findsNothing);
    expect(reqUnsignedPropGenFinder, findsNothing);
    expect(signProposalFinder, findsNothing);
    expect(sendSignedPropFinder, findsNothing);
  });
}
