import "dart:async";

import "package:chat_gpt_sdk/chat_gpt_sdk.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";

void main() {
  runApp(
    MaterialApp(
      theme: ThemeData(brightness: Brightness.dark),
      debugShowCheckedModeBanner: false,
      home: const Page(),
    ),
  );
}

class Page extends StatefulWidget {
  const Page({super.key});

  @override
  State<Page> createState() => _PageState();
}

class _PageState extends State<Page> {
  List<List> conversation = [];
  StreamSubscription<CompleteResponse?>? subscription;
  var controller = TextEditingController();
  late ChatGPT api;
  List<List> data = [
    [TextEditingController(), "text-davinci-003", "model"],
    [TextEditingController(), 2024, "max Tokens"],
    [TextEditingController(), 0.0, "frequency Penalty"],
    [TextEditingController(), 0.0, "presence Penalty"],
    [TextEditingController(), 1.0, "temperature"],
    [TextEditingController(), 1.0, "top p"],
  ];
  void askQandA() {
    conversation.add([controller.text, false]);
    setState(() => controller.text = "");
    subscription = api
        .onCompleteStream(
          request: CompleteReq(
            prompt: conversation.last[0],
            model: data[0][1],
            max_tokens: data[1][1],
            frequency_penalty: data[2][1],
            presence_penalty: data[3][1],
            temperature: data[4][1],
            top_p: data[5][1],
          ),
        )
        .asBroadcastStream()
        .listen((res) => setState(() => conversation.add([res, true])));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async => update(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: conversation.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.all(10),
                child: InkWell(
                  onLongPress: () async => Clipboard.setData(
                    ClipboardData(
                      text: conversation[index][1]
                          ? conversation[index][0].choices.last.text
                          : conversation[index][0],
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: conversation[index][1]
                          ? Colors.blue.withAlpha(9 * 255 ~/ 10)
                          : Colors.orange.withAlpha(9 * 255 ~/ 10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: conversation[index][1]
                        ? const EdgeInsets.only(left: 10, right: 50)
                        : const EdgeInsets.only(right: 10, left: 50),
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      conversation[index][1]
                          ? conversation[index][0].choices.last.text
                          : conversation[index][0],
                    ),
                  ),
                ),
              ),
            ),
          ),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              suffix: IconButton(
                onPressed: askQandA,
                icon: const Icon(
                  Icons.send,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    unawaited(subscription?.cancel());
    api.close();
    super.dispose();
  }

  @override
  void initState() {
    api = ChatGPT.instance.builder(
      "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",
      baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 7000)),
    );
    super.initState();
  }

  Future<void> update() async {
    final bool answer = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Settings"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Save"),
          ),
        ],
        content: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            height: 300,
            width: 310,
            child: ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(width: 100, child: Text(data[index][2])),
                  const SizedBox(width: 5),
                  SizedBox(
                    width: 100,
                    child: Text(data[index][1].toString()),
                  ),
                  const SizedBox(width: 5),
                  SizedBox(
                    width: 100,
                    child: TextField(controller: data[index][0]),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    if (!answer) {
      return;
    }
    data[0][0].text == ""
        ? null
        : setState(() {
            data[0][1] = data[0][0].text;
            data[0][0].text = "";
          });
    data[1][0].text == ""
        ? null
        : setState(() {
            data[1][1] = int.parse(data[1][0].text);
            data[1][0].text = "";
          });
    data[2][0].text == ""
        ? null
        : setState(() {
            data[2][1] = double.parse(data[2][0].text);
            data[2][0].text = "";
          });
    data[3][0].text == ""
        ? null
        : setState(() {
            data[3][1] = double.parse(data[3][0].text);
            data[3][0].text = "";
          });
    data[4][0].text == ""
        ? null
        : setState(() {
            data[4][1] = double.parse(data[4][0].text);
            data[4][0].text = "";
          });
    data[5][0].text == ""
        ? null
        : setState(() {
            data[5][1] = double.parse(data[5][0].text);
            data[5][0].text = "";
          });
  }
}
