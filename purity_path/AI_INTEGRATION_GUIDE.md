# AI Integration Guide for Purity Path

## Overview
This guide covers how to integrate AI capabilities into your Purity Path recovery app.

## ✅ What Has Been Created

### 1. Gemini AI Service (`lib/data/services/gemini_ai_service.dart`)
A complete service for AI-powered recovery support with methods for:
- General recovery support chat
- Personalized motivation generation
- Trigger analysis and coping strategies
- Islamic guidance with Quranic references
- Emergency support during strong urges
- Recovery plan suggestions

### 2. AI Counselor UI (`lib/view/navigations/ai_counselor.dart`)
A beautiful chat interface with:
- Real-time messaging with AI
- Quick action buttons (Emergency, Motivation, Islamic Guidance)
- Message history
- Clean, modern design
- Loading states

## 🚀 Setup Instructions

### ✅ Step 1: API Keys Already Added!
Good news! Three Gemini API keys have already been configured with automatic fallback:
- If the first key hits a rate limit, it automatically switches to the second
- If the second fails, it tries the third
- The system remembers which key is working and uses it first next time

### Step 2: Install Dependencies
Run in terminal:
```bash
flutter pub get
```

### Step 3: Add Route to Navigation
Open `lib/utils/routes/routes.dart` and add the AI Counselor route:
```dart
import 'package:purity_path/view/navigations/ai_counselor.dart';

// In your routes
case RoutesName.aiCounselor:
  return MaterialPageRoute(builder: (_) => const AICounselorPage());
```

Add to `lib/utils/routes/routes_name.dart`:
```dart
class RoutesName {
  // ... existing routes
  static const String aiCounselor = 'ai_counselor';
}
```

### Step 5: Add Menu Item
In your home page or settings, add a button to navigate to AI Counselor:
```dart
ElevatedButton(
  onPressed: () {
    Navigator.pushNamed(context, RoutesName.aiCounselor);
  },
  child: const Text('Talk to AI Counselor'),
)
```

## 💡 Usage Examples

### 1. Chat Interface
Users can type any question or concern, and the AI will provide Islamic-based recovery support.

### 2. Emergency Support
```dart
// In your code when user clicks emergency button
final response = await GeminiAIService.getEmergencySupport();
```

### 3. Daily Motivation
```dart
final motivation = await GeminiAIService.generateMotivation(
  cleanStreak: userCleanStreak,
  totalCleanDays: userTotalDays,
  currentPhase: 'Phase 2',
);
```

### 4. Trigger Analysis
```dart
final advice = await GeminiAIService.analyzeTriggers(
  trigger: 'Social media scrolling',
  situation: 'Late night, alone in bedroom',
);
```

## 🔒 Security Best Practices

### Option 1: Environment Variables (Recommended for Production)
Create a `.env` file (add to `.gitignore`):
```
GEMINI_API_KEY=AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXX
```

Use `flutter_dotenv` package:
```yaml
dependencies:
  flutter_dotenv: ^5.1.0
```

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

await dotenv.load();
final apiKey = dotenv.env['GEMINI_API_KEY'];
```

### Option 2: Backend API (Most Secure)
Create a simple backend (Node.js/Firebase Functions) that:
1. Stores the API key securely
2. Your app calls your backend
3. Your backend calls Gemini API
4. Returns response to app

Example Firebase Function:
```javascript
exports.getAIResponse = functions.https.onCall(async (data, context) => {
  const userMessage = data.message;
  // Call Gemini API with your secret key
  // Return response
});
```

## 🎯 Alternative AI Options

### Option 2: OpenAI ChatGPT
**Pros:** More powerful, better responses
**Cons:** Requires payment ($0.002 per request), requires credit card

```dart
class OpenAIService {
  static const String _apiKey = 'sk-XXXXXXXXXXXXX';
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';

  static Future<String> getResponse(String message) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {'role': 'system', 'content': 'You are an Islamic recovery counselor...'},
          {'role': 'user', 'content': message}
        ],
        'max_tokens': 500,
      }),
    );
    
    final data = jsonDecode(response.body);
    return data['choices'][0]['message']['content'];
  }
}
```

### Option 3: Anthropic Claude
**Pros:** Strong safety, good at reasoning
**Cons:** Requires payment, US-based

Similar implementation to OpenAI.

### Option 4: Local AI (Offline)
**Pros:** Free, works offline, private
**Cons:** Limited capability, larger app size

Use packages like:
- `llama_cpp_dart` for running small models locally
- `tensorflow_lite` for simple ML tasks

### Option 5: Hugging Face Free API
**Pros:** Free tier available
**Cons:** Rate limits, less reliable

## 📊 Cost Comparison

| Provider | Free Tier | Paid |
|----------|-----------|------|
| Google Gemini | 60 requests/min | $0.00025/request |
| OpenAI GPT-3.5 | None | $0.002/request |
| OpenAI GPT-4 | None | $0.03/request |
| Anthropic Claude | None | $0.008/request |
| Hugging Face | Limited | Free (open source) |

## 🎨 UI Integration Ideas

### 1. Home Screen Widget
```dart
Card(
  child: ListTile(
    leading: Icon(Icons.psychology),
    title: Text('AI Counselor'),
    subtitle: Text('Get instant support'),
    onTap: () => Navigator.pushNamed(context, RoutesName.aiCounselor),
  ),
)
```

### 2. Floating Action Button
```dart
FloatingActionButton(
  onPressed: () async {
    final help = await GeminiAIService.getEmergencySupport();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('AI Support'),
        content: Text(help),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  },
  child: Icon(Icons.sos),
)
```

### 3. Daily Check-in with AI
```dart
// After user completes daily check-in
final motivation = await GeminiAIService.generateMotivation(
  cleanStreak: cleanStreak,
  totalCleanDays: totalDays,
);

// Show in a beautiful card
```

## 🔄 Advanced Features

### 1. Conversation History
Store chat history in Firebase:
```dart
await FirebaseFirestore.instance
  .collection('users')
  .doc(userId)
  .collection('ai_chats')
  .add({
    'message': message,
    'response': aiResponse,
    'timestamp': FieldValue.serverTimestamp(),
  });
```

### 2. Personalized AI Based on User Data
```dart
final userProfile = await getUserProfile();
final context = '''
User info:
- Clean streak: ${userProfile.cleanStreak} days
- Main triggers: ${userProfile.triggers.join(', ')}
- Current phase: ${userProfile.currentPhase}
- Previous relapses: ${userProfile.relapseCount}
''';

final response = await GeminiAIService.getRecoverySupport(
  userMessage: message,
  context: context,
);
```

### 3. Scheduled AI Messages
```dart
// Send daily motivational messages using notifications
Future<void> scheduleDailyAIMotivation() async {
  final motivation = await GeminiAIService.generateMotivation(...);
  await NotificationService.showNotification(
    title: 'Daily Motivation',
    body: motivation,
  );
}
```

## ⚠️ Important Notes

1. **API Key Security:** Never commit API keys to GitHub
2. **Rate Limits:** Gemini free tier has 60 requests/minute
3. **Error Handling:** Always handle network errors gracefully
4. **User Privacy:** Don't send sensitive personal data to AI
5. **Internet Required:** AI features need internet connection
6. **Content Filtering:** AI responses may occasionally be inappropriate

## 🐛 Troubleshooting

### Error: "API key not valid"
- Check that you copied the entire key
- Verify key is activated in Google AI Studio
- Check for extra spaces in the key

### Error: "Resource exhausted"
- You've hit the rate limit
- Wait a minute and try again
- Consider implementing request throttling

### Error: "Safety settings blocked response"
- Adjust safety settings in the code
- Rephrase the prompt to be less triggering

### Slow Responses
- Reduce `maxOutputTokens` in config
- Use shorter system prompts
- Check your internet connection

## 📱 Next Steps

1. ✅ Set up Gemini API key
2. ✅ Test the AI Counselor page
3. Add AI features to other parts of app:
   - Emergency urge support button
   - Daily check-in AI responses
   - Trigger analysis in journal
   - Personalized recovery tips
4. Implement conversation history
5. Add voice input/output (optional)
6. Create analytics for AI usage

## 📞 Support

If you need help:
- Google AI Studio Docs: https://ai.google.dev/
- Flutter HTTP Package: https://pub.dev/packages/http
- Gemini API Reference: https://ai.google.dev/api/rest

Good luck with your AI integration! 🚀
