import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../services/chatbotService.dart';

class ChatbotPage extends StatefulWidget {
  @override
  _ChatbotPageState createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  String? _chatbotUrl;  // Variable to store the chatbot URL
  bool _isLoading = true;  // Flag to indicate loading state
  late WebViewController _webViewController;  // Controller to manage WebView

  @override
  void initState() {
    super.initState();
    // Initialize the WebView platform for Android
    WebView.platform = SurfaceAndroidWebView(); // Required for Android

    // Fetch the chatbot URL when the page loads
    _getChatbotUrl();
  }

  // Fetch chatbot URL from the service
  _getChatbotUrl() async {
    try {
      String url = await ChatbotService().getChatbotUrl();  // Get URL from service
      setState(() {
        _chatbotUrl = url;  // Store the fetched URL
        _isLoading = false;  // Set loading state to false
      });
    } catch (e) {
      setState(() {
        _isLoading = false;  // Set loading state to false on error
      });
      // Handle error (show error message or fallback)
      print("Error fetching chatbot URL: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AI Doctor Chatbot"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);  // Go back to the home page
          },
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())  // Show loading spinner while fetching URL
          : _chatbotUrl == null
          ? Center(child: Text("Failed to load chatbot"))  // Show error message if URL is null
          : WebView(
        initialUrl: _chatbotUrl,  // Use the fetched URL in the WebView
        javascriptMode: JavascriptMode.unrestricted,  // Enable JavaScript
        onWebViewCreated: (WebViewController webViewController) {
          _webViewController = webViewController;  // Initialize the controller
        },
        onPageStarted: (String url) {
          setState(() {
            _isLoading = true;  // Set loading state to true when page starts loading
          });
        },
        onPageFinished: (String url) {
          setState(() {
            _isLoading = false;  // Set loading state to false when page finishes loading
          });
        },
        navigationDelegate: (NavigationRequest request) {
          if (request.url.startsWith("https://")) {
            // Allow navigation if the URL starts with "https://"
            return NavigationDecision.navigate;
          }
          return NavigationDecision.prevent;  // Prevent other URLs
        },
      ),
    );
  }
}
