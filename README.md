# 🚀 CodeSensei – AI Code Review App

CodeSensei is an AI-powered Flutter app that reviews, optimizes, and transpiles code in real time using multiple AI APIs. It supports code uploads, intelligent feedback, and generates PDF reports — all in one place.

---

## 📱 UI Screenshots

<p float="left">
  <img src="assets/Login.jpeg" width="200" height="400"/>
  <img src="assets/HomePage.jpeg" width="200" height="400"/>
  <img src="assets/Review Page.jpeg" width="200" height="400"/>
  <img src="assets/CodeTranspilerScreen.jpeg" width="200" height="400"/>
</p>

---

## 🌟 Features

- 🔍 AI-Powered Code Review with Suggestions
- 📤 Upload or Paste Code for Instant Feedback
- 🔄 Code Transpiler: Convert Code Between Languages
- 🧾 Generate and Download Code Reports as PDF
- 🔐 Google Sign-In Authentication
- 📦 State Management with **Flutter BLoC & Cubit**

---

## 🛠️ Tech Stack

**Frontend:** Flutter, Dart  
**Backend:** Spring Boot  
**Database:** MySQL  
**State Management:** Flutter BLoC, Cubit  
**AI APIs:** Gemini AI, Groq AI, DeepSeek AI  
**Deployment:** Railway

---

## 🧠 AI Integration

- Integrated **Gemini AI**, **Groq AI**, and **DeepSeek AI** to analyze code structure and logic.
- Detects bugs, anti-patterns, and suggests optimized or cleaner code.
- Supports **multi-language transpilation** (e.g., Dart → JavaScript).

---

## 🚀 Deployment

- **Frontend:** _Not yet deployed_  
- **Backend:** [sparkling-flow-production.up.railway.app](https://sparkling-flow-production.up.railway.app)

---

## 🧪 Installation (For Local Setup)

```bash
# Clone the repo
git clone https://github.com/GAURANG1205/codesensei.git

# Navigate to frontend
cd codesensei/Frontend
flutter pub get
flutter run

# Navigate to backend
cd ../Backend
./mvnw spring-boot:run
