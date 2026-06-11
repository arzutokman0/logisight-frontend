# Ürün Gereksinim Dokümanı (PRD) - LogiSight 📄

## 1. Proje Özeti
LogiSight, lojistik yöneticileri için geliştirilmiş, sürücü sensör verilerini yapay zeka ile analiz ederek güvenlik skorları üreten ayrık mimarili (decoupled) bir web uygulamasıdır.

## 2. Kullanıcı Hikayeleri (User Stories)
* **Yönetici olarak;** sisteme giriş yapabilmeli ve aktif seferlerin listesini görebilmeliyim.
* **Yönetici olarak;** belirli bir seferi başlattığımda, sistemin sensör verilerini arka planda yapay zekaya gönderip sonuçları getirmesini beklerim.
* **Sistem olarak;** gelen sensör anormalliklerini (örn. çok yüksek ivme) tespit edip, model tahminiyle birlikte arayüze anında yanıt dönmeliyim.

## 3. Teknik Mimari & Tech Stack
* **Frontend:** Flutter Web (Netlify üzerinde barındırılmaktadır).
* **Backend:** Python / FastAPI (Render üzerinde barındırılmaktadır).
* **Yapay Zeka:** Scikit-learn (Tahmine dayalı ML Modeli) ve Google Gemini API (Doğal dil işleme ve veri yorumlama).
* **İletişim:** RESTful API mimarisi, JSON formatında veri transferi.

## 4. Başarı Kriterleri
* Sistemin uçtan uca çalışır durumda, canlı (deployed) linkler üzerinden erişilebilir olması.
* Backend API'nin 200 OK yanıtları ile sensör verilerini hatasız işlemesi.