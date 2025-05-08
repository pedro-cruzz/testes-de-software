from selenium import webdriver
from selenium.webdriver.common.keys import Keys
import time

options = webdriver.ChromeOptions()
driver = webdriver.Chrome(options=options)

try:
    options.add_argument("--user-data-dir=C:/Users/pedro/AppData/Local/Google/Chrome/User Data")
    options.add_argument("--profile-directory=Default")
    driver.get("https://web.whatsapp.com")

    # Aguarda o carregamento do WhatsApp Web
    time.sleep(50)  # Ajuste o tempo conforme necessário para garantir o carregamento completo

    # Localiza o contato pelo nome
    search_box = driver.find_element("xpath", '//div[@contenteditable="true"][@data-tab="3"]')
    search_box.click()
    search_box.send_keys("Danyllo")
    time.sleep(2)  # Aguarda o resultado da busca aparecer
    search_box.send_keys(Keys.ENTER)

    # Envia a mensagem
    message_box = driver.find_element("xpath", '//div[@contenteditable="true"][@data-tab="10"]')
    message_box.click()
    message_box.send_keys("Olá, esta é uma mensagem enviada automaticamente pelo Selenium!")
    message_box.send_keys(Keys.ENTER)

finally:
    # Fecha o navegador
    driver.quit()



