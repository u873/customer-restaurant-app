import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import 'package:customer_estaurant_app/core/theme/app_colors.dart';
import '../controller/content_controller.dart';

class ContentScreen extends StatefulWidget {
  final String type;
  final VoidCallback onClose;

  const ContentScreen({super.key, required this.type, required this.onClose});

  @override
  State<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  final ContentController _controller = ContentController();

  @override
  void initState() {
    super.initState();
    _controller.fetchContent();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAbout = widget.type == 'about';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 18, 14, 0),
              child: Row(
                children: [
                  InkWell(
                    onTap: widget.onClose,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.textSecondary.withOpacity(0.4),
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: AppColors.iconPrimary,
                        size: 18,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        isAbout ? "About Us" : "Terms & Conditions",
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 36, height: 36),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  if (_controller.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (_controller.errorMessage != null) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          _controller.errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  }

                  final content = _controller.content;

                  if (content == null) {
                    return const Center(
                      child: Text(
                        "No content available",
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }

                  final html = isAbout
                      ? content.aboutUs
                      : content.termsAndConditions;

                  if (html.trim().isEmpty) {
                    return const Center(
                      child: Text(
                        "No content available",
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                      decoration: BoxDecoration(
                        color: AppColors.foodCardBackground,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: HtmlWidget(
                        html,
                        textStyle: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          height: 1.6,
                        ),

                        customStylesBuilder: (element) {
                          if (element.localName == 'h1' ||
                              element.localName == 'h2' ||
                              element.localName == 'h3') {
                            return {
                              'color': '#FFFFFF',
                              'font-size': '15px',
                              'font-weight': '600',
                              'margin': '0 0 10px 0',
                            };
                          }

                          if (element.localName == 'p') {
                            return {
                              'color': '#9B9B9B',
                              'font-size': '11px',
                              'line-height': '1.6',
                              'margin': '0 0 10px 0',
                            };
                          }

                          if (element.localName == 'strong' ||
                              element.localName == 'b') {
                            return {'color': '#FFFFFF', 'font-weight': '600'};
                          }

                          if (element.localName == 'li') {
                            return {
                              'color': '#9B9B9B',
                              'font-size': '11px',
                              'line-height': '1.6',
                            };
                          }

                          return null;
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
