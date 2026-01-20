$env:JAVA_HOME="C:\Program Files\Android\Android Studio\jbr"
Set-Location android
./gradlew signingReport
Read-Host -Prompt "İşlem tamamlandı. SHA-1 kodunu yukarıda görebilirsiniz. Çıkmak için Enter'a basın"
