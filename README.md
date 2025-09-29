# chatgpt_clone

## 📌 Project Overview
A Flutter-based AI chat application that allows users to interact with AI models via text and images. The app features multi-modal messaging, conversation management, markdown rendering, and dynamic theming, built with clean architecture and robust state management.


## 🚀 Tech Stack

- **Framework & Language:** Flutter, Dart  
- **State Management:** BLoC (flutter_bloc) for reactive state updates  
- **Backend Communication:** REST API using `http` & `MultipartRequest`  
- **Architecture Patterns:** Clean Architecture, Repository Pattern, Singleton Pattern for services  
- **UI/UX:** Responsive design, markdown support


## 🔄 State Management & Data Flow

1. **Event:** User action (send message, change theme, select model)  
2. **BLoC:** Handles business logic and API communication  
3. **State:** Updated state emitted to rebuild UI  
4. **UI:** Widgets reactively display new state  

**Key BLoCs:**  
- `ChatBloc` – Manages conversations, messages, and AI responses  
- `ThemeBloc` – Handles light/dark mode  
- `ModelBloc` – Manages AI model selection and persistence  


## 📱 Features

- **Chat Functionality:**  
  - Text & image messaging  
  - Markdown rendering for AI responses  
  - Real-time conversation updates  

- **Conversation Management:**  
  - Create, read, update, delete conversations  
  - Search and rename conversations inline  

- **AI Integration:**  
  - Supports multiple AI models  
  - Image processing & display from AI responses  

- **UI/UX Enhancements:**  
  - Dynamic light/dark themes  
  - Smooth transitions and animations  
  - Responsive layout for mobile devices  


## 🔌 Backend Integration

- **BackendService:** Handles HTTP requests to Node.js backend  
- **Supported Operations:**  
  - Sending messages with optional images  
  - Conversation CRUD operations  
  - AI model selection & response handling  

---

## Backend of this Perplexity AI + ChatGPt clone

Click [here](https://github.com/tushar11kh/perplexiity_chatgpt_clone_backend) to go to backend.