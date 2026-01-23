import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../../widgets/bubble_chat.dart';
import '../../../widgets/bot_response.dart';

class ChatTab extends StatelessWidget {
  const ChatTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView(
        children: [
          Container(
            width: 100,
            height: 100,
            alignment: Alignment.center,
            child: Image.asset(
              'assets/images/bot_logo.png',
              width: 100,
              height: 100,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.auto_awesome,
                  size: 14,
                  color: AppColors.primary,
                );
              },
            ),
          ),
          SizedBox(height: 16),
          Container(
            alignment: Alignment.centerRight,
            child:
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                BubbleChat(timestamp: '3:40', text: 'imagen', color: AppColors.primaryDark, textColor: AppColors.white, imageUrl: 'http://192.168.100.73:8000/images/123/aff58335-b558-4a1b-819e-0213d0abaf61_ISIC_6653456.jpg',),
                BubbleChat(
                  text: 'hola Jose delgado asdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasd',
                  timestamp: '3:90',
                  color: AppColors.primaryDark,
                  textColor: AppColors.white,
                ),
                BotResponse(text: 'Hola que tal tu día'),
              ]
            ),
          )

        ]
      ),
    );
  }
}
