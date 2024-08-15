import 'package:ayahhebat/src/consts/app_styles.dart';
import 'package:flutter/material.dart';

import '../api/question_api.dart';
import '../consts/app_colors.dart';
import '../models/question_model.dart';
import '../widgets/app_bar_builder.dart';

class FaqPage extends StatefulWidget {
  const FaqPage({super.key});

  @override
  State<FaqPage> createState() => FaqPageState();
}

class FaqPageState extends State<FaqPage> {
  QuestionApi questionApi = QuestionApi();
  TextEditingController questionController = TextEditingController();

  void showSnackBar(String message, Color? backgroundColor) {
    SnackBar snackBar = SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  createQuestion() async {
    String question = questionController.text;

    if (question == "") {
      showSnackBar(
          "Mohon isi pertanyaan terlebih dahulu", AppColors.accentColor);
    } else {
      try {
        bool success = await questionApi.createQuestion(question);
        if (success) {
          showSnackBar("Pertanyaan anda sudah dikirim, mohon tunggu",
              AppColors.greenColor);
        } else {
          showSnackBar("Pertanyaan gagal dikirim", AppColors.redColor);
        }
      } catch (e) {
        String errorString = e.toString();
        String errorMessage = errorString
            .split(":")[2]
            .replaceAll('"', '')
            .replaceAll('}', '')
            .trim();
        final snackBar = SnackBar(
          content: Text(errorMessage),
          backgroundColor: AppColors.redColor,
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      appBar: AppBarBuilder(
        title: "FAQ",
        showBackButton: true,
        showCancelButton: false,
        onBackButtonPressed: () {
          Navigator.pop(context);
        },
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              children: [
                Text(
                  "Pertanyaan yang Sering Diajukan",
                  style: AppStyles.heading2TextStyle,
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: FutureBuilder(
                    future: questionApi.getAllQuestionWithAnswer(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primaryColor),
                            ),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Text("Error: ${snapshot.error}");
                      } else if (snapshot.data!.isEmpty || !snapshot.hasData) {
                        return const Center(child: Text("No data available"));
                      } else {
                        return ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            Question question = snapshot.data![index];
                            return ExpandableContainer(
                                question: question, index: index);
                          },
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
          Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Material(
                color: AppColors.white10Color,
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 24, right: 24, bottom: 16),
                      child: TextFormField(
                        style: AppStyles.labelTextStyle,
                        decoration: InputDecoration(
                            hintText: "Ajukan pertanyaan kepada admin",
                            hintStyle: AppStyles.hintTextStyle,
                            suffixIcon: IconButton(
                              icon: Icon(Icons.send_rounded),
                              color: AppColors.primaryColor,
                              onPressed: () {
                                createQuestion();
                                questionController.clear();
                              },
                            ),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(100),
                                borderSide: BorderSide(color: Colors.black))),
                        controller: questionController,
                        // maxLines: null,
                      ),
                    )
                  ],
                ),
              ))
        ],
      ),
    );
  }
}

class ExpandableContainer extends StatefulWidget {
  const ExpandableContainer({
    super.key,
    required this.question,
    required this.index,
  });

  final Question question;
  final int index;

  @override
  State<ExpandableContainer> createState() => _ExpandableContainerState();
}

class _ExpandableContainerState extends State<ExpandableContainer> {
  bool isExpanded = false;

  void toggleExpand() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  void checkIndexZero(int index) {
    if (index != 0) {
      return;
    } else {
      isExpanded = true;
    }
  }

  @override
  void initState() {
    super.initState();
    checkIndexZero(widget.index);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.grey)),
      child: Column(
        children: [
          ListTile(
            title: Text(widget.question.question, style: AppStyles.labelBoldTextStyle,),
            trailing: IconButton(
                onPressed: toggleExpand,
                icon: Icon(
                  isExpanded ? Icons.close : Icons.expand_more,
                  color: AppColors.primaryColor,
                )),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.symmetric( vertical: 10, horizontal: 16),
              child: Text(widget.question.answer ?? "", style: AppStyles.labelTextStyle, textAlign: TextAlign.justify,),
            )
        ],
      ),
    );
  }
}
