alert("Archivo JS vinculado correctamente");
// formulario.js
document.addEventListener("DOMContentLoaded", () => {
  const btnLogin = document.getElementById("btn-login");
  const btnRegister = document.getElementById("btn-register");
  const formLogin = document.getElementById("login-form");
  const formRegister = document.getElementById("register-form");

  // Verifica que los elementos existan
  if (!btnLogin || !btnRegister || !formLogin || !formRegister) {
    console.error("Error: No se encontraron elementos del formulario en el HTML.");
    return;
  }

  // Alternar pestañas
  btnLogin.addEventListener("click", () => {
    btnLogin.classList.add("active");
    btnRegister.classList.remove("active");
    formLogin.classList.add("active");
    formRegister.classList.remove("active");
  });

  btnRegister.addEventListener("click", () => {
    btnRegister.classList.add("active");
    btnLogin.classList.remove("active");
    formRegister.classList.add("active");
    formLogin.classList.remove("active");
  });

  document.addEventListener("DOMContentLoaded", function() {
  alert("Archivo JS vinculado correctamente"); // <-- prueba visual

  const departamentoSelect = document.getElementById("departamento");
  const ciudadSelect = document.getElementById("ciudad");

  // Lista de departamentos y ciudades
  const ciudadesPorDepartamento = {
    antioquia: ["Medellín", "Envigado", "Bello", "Rionegro", "La Ceja", "Itagüí"],
    cundinamarca: ["Bogotá", "Soacha", "Chía", "Zipaquirá", "Facatativá"],
    boyaca: ["Tunja", "Duitama", "Sogamoso", "Villa de Leyva", "Paipa"],
    atlantico: ["Barranquilla", "Soledad", "Puerto Colombia", "Malambo", "Sabanalarga"],
    valle: ["Cali", "Palmira", "Buenaventura", "Buga", "Tuluá"]
  };

  // Cuando cambie el departamento
  departamentoSelect.addEventListener("change", function() {
    const departamento = departamentoSelect.value;
    const ciudades = ciudadesPorDepartamento[departamento] || [];

    // Limpiar ciudades anteriores
    ciudadSelect.innerHTML = "<option value=''>Selecciona una ciudad</option>";

    // Agregar nuevas ciudades
    ciudades.forEach(ciudad => {
      const option = document.createElement("option");
      option.value = ciudad.toLowerCase();
      option.textContent = ciudad;
      ciudadSelect.appendChild(option);

      // Acción al hacer clic en el botón Ingreso
document.getElementById("btnIngreso").addEventListener("click", () => {
  window.location.href = "ingreso.html";
});

    });
  });
});



});
