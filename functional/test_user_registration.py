import pytest
from selenium import webdriver
from selenium.webdriver.common.by import By
import requests

class TestUserRegistration:
    
    def setup_method(self):
        # Configurar el driver de Selenium (usa el driver correcto para tu navegador)
        self.driver = webdriver.Chrome(executable_path="/path/to/chromedriver")
        self.driver.get("https://www.example.com/register")

    def teardown_method(self):
        # Cerrar el navegador después de la prueba
        self.driver.quit()

    def test_registration_form_and_api(self):
        # Paso 1: Completar y enviar el formulario de registro
        self.driver.findElement(By.NAME, 'username').sendKeys('new_user')
        self.driver.findElement(By.NAME, 'email').sendKeys('new_user@example.com')
        self.driver.findElement(By.NAME, 'password').sendKeys('password123')
        self.driver.findElement(By.NAME, 'submit').click()

        # Verificar que la página muestre un mensaje de confirmación
        confirmation_message = self.driver.findElement(By.ID, 'success_message').text
        assert confirmation_message == "Registration successful!", "Error: Message not displayed correctly."

        # Paso 2: Verificar que la API recibió los datos correctamente
        api_url = "https://api.example.com/users"
        headers = {'Authorization': 'Bearer YOUR_TOKEN', 'Content-Type': 'application/json'}
        response = requests.get(api_url, headers=headers)
        
        assert response.status_code == 200, "Error: API did not return status code 200."
        
        # Verificar que el usuario ha sido registrado correctamente en la API
        users = response.json()
        new_user = next((user for user in users if user['email'] == 'new_user@example.com'), None)
        assert new_user is not None, "Error: User not found in the API."
        assert new_user['username'] == 'new_user', "Error: Username does not match."
