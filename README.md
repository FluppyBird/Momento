# 🛠️ Momento Project - Environment Setup Guide

> **Version Info**
> - Ruby: `3.3.7`
> - Rails: `7.1.5`

---

## ✅ Environment Setup Steps

### 1. 💎 Install Ruby & Rails

```bash
# Ensure Ruby 3.3.7 is installed
ruby -v

# Install Bundler
gem install bundler

# Install specific version of Rails
gem install rails -v 7.1.5
```

---

### 2. 📦 Install Dependencies

```bash
bundle install
```

---

### 3. 🗄️ Setup the Database

```bash
rails db:create
rails db:migrate
rails db:seed
```

---

### 4. 🧹 Clean Cache (Windows-specific)

```bash
rails tmp:cache:clear
```

---

### 5. 🚀 Start the Rails Server

```bash
rails s
```

Open your browser and navigate to:  
[http://localhost:3000](http://localhost:3000)

---