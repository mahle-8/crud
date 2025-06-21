
document.addEventListener('DOMContentLoaded', async ()=> {
  document.querySelector('body').style.display = 'none';
  document.querySelector('body').style.opacity = 0;
 
  await checkAuth();
  console.log('login controller has been loaded');
  fadeInElement(document.querySelector('body'), 1000);
  // Initialize the loading screen
    
});


const objForm = new Form('loginForm', 'edit-input');
const appStorage = new AppStorage();
const myForm = objForm.getForm();

let documentData = "";
let httpMethod = "";
let endpointUrl = "";

myForm.addEventListener('submit', async (e) => {
  e.preventDefault();

  if (!objForm.validateForm()) {
    console.log("Formulario inválido");
    return;
  }

  toggleLoading(true);

  try {
    const httpMethod = METHODS[1]; // POST
    const endpointUrl = URL_LOGIN;
    const token = "";
    const documentData = objForm.getDataForm();

    const response = await getServicesAuth(documentData, httpMethod, endpointUrl, token);
    const data = await response.json();

    console.log("Respuesta backend:", data);

    if (!data.user || !data.user.token) {
      console.log("Error en login: token no recibido");
      alert("Usuario o contraseña incorrectos");
      return;
    }

    appStorage.setItem(KEY_TOKEN, data.user.token);
    console.log("Login exitoso");
    window.location.href = '../../';

  } catch (error) {
    console.error("Error en la petición:", error);
  } finally {
    toggleLoading(false);
  }
});


window.addEventListener('load', () => {

});

