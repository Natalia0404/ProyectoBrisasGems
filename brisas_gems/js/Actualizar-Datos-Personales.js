document.addEventListener('DOMContentLoaded', function() {
    // Elementos del DOM
    const updateForm = document.getElementById('updateForm');
    const successAlert = document.getElementById('successAlert');
    const errorAlert = document.getElementById('errorAlert');
    const profilePictureInput = document.getElementById('profilePicture');
    const currentProfilePic = document.getElementById('currentProfilePic');
    const removePictureBtn = document.getElementById('removePicture');
    const newPasswordInput = document.getElementById('newPassword');
    const strengthBar = document.getElementById('strengthBar');
    const strengthLabel = document.getElementById('strengthLabel');
    const cancelBtn = document.getElementById('cancelBtn');
    
    // Cargar datos del usuario
    function loadUserData() {
        // Simulación de datos - en producción sería una llamada AJAX
        const userData = {
            nombres: "María José",
            apellidos: "García López",
            documento: "12345678A",
            email: "maria@example.com",
            telefono: "5551234567",
            fotoPerfil: "placeholder-profile.jpg"
        };
        
        // Llenar formulario
        document.getElementById('nombres').value = userData.nombres;
        document.getElementById('apellidos').value = userData.apellidos;
        document.getElementById('documento').value = userData.documento;
        document.getElementById('email').value = userData.email;
        document.getElementById('telefono').value = userData.telefono;
        currentProfilePic.src = userData.fotoPerfil;
    }
    
    // Manejar cambio de foto de perfil
    profilePictureInput.addEventListener('change', function(e) {
        const file = e.target.files[0];
        if (file && file.type.match('image.*')) {
            const reader = new FileReader();
            reader.onload = function(event) {
                currentProfilePic.src = event.target.result;
            };
            reader.readAsDataURL(file);
        } else {
            showError('Por favor selecciona una imagen válida (JPEG, PNG)');
            this.value = '';
        }
    });
    
    // Eliminar foto de perfil
    removePictureBtn.addEventListener('click', function() {
        currentProfilePic.src = 'default-profile.jpg';
        profilePictureInput.value = '';
    });
    
    // Validar fortaleza de contraseña
    newPasswordInput.addEventListener('input', function() {
        const password = this.value;
        let strength = 0;
        
        // Reglas de validación
        if (password.length >= 8) strength += 1;
        if (/\d/.test(password)) strength += 1;
        if (/[a-z]/.test(password) && /[A-Z]/.test(password)) strength += 1;
        if (/[^a-zA-Z0-9]/.test(password)) strength += 1;
        
        // Actualizar UI
        const width = (strength / 4) * 100;
        strengthBar.style.width = width + '%';
        
        // Establecer color y texto según fortaleza
        const levels = [
            { color: '#dc3545', text: 'Débil' },
            { color: '#ffc107', text: 'Moderada' },
            { color: '#28a745', text: 'Fuerte' },
            { color: '#0a8048', text: 'Excelente' }
        ];
        
        const level = Math.min(strength, 3);
        strengthBar.style.backgroundColor = levels[level].color;
        strengthLabel.textContent = `Seguridad: ${levels[level].text}`;
        strengthLabel.style.color = levels[level].color;
    });
    
    // Mostrar mensaje de error
    function showError(message) {
        errorAlert.querySelector('p').textContent = message;
        errorAlert.style.display = 'flex';
        setTimeout(() => {
            errorAlert.style.display = 'none';
        }, 5000);
    }
    
    // Mostrar mensaje de éxito
    function showSuccess(message) {
        successAlert.querySelector('p').textContent = message;
        successAlert.style.display = 'flex';
        setTimeout(() => {
            successAlert.style.display = 'none';
        }, 5000);
    }
    
    // Validar formulario
    function validateForm() {
        let isValid = true;
        
        // Validar campos requeridos
        const requiredFields = [
            { id: 'nombres', errorId: 'nombresError', message: 'Por favor ingresa tus nombres' },
            { id: 'apellidos', errorId: 'apellidosError', message: 'Por favor ingresa tus apellidos' },
            { id: 'documento', errorId: 'documentoError', message: 'Por favor ingresa tu documento' },
            { id: 'email', errorId: 'emailError', message: 'Por favor ingresa un correo válido' }
        ];
        
        requiredFields.forEach(field => {
            const element = document.getElementById(field.id);
            const errorElement = document.getElementById(field.errorId);
            
            if (element.value.trim() === '') {
                errorElement.textContent = field.message;
                errorElement.style.display = 'block';
                isValid = false;
            } else {
                errorElement.style.display = 'none';
            }
        });
        
        // Validar formato de email
        const email = document.getElementById('email').value.trim();
        if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
            document.getElementById('emailError').style.display = 'block';
            isValid = false;
        }
        
        // Validar contraseña si se está cambiando
        const currentPassword = document.getElementById('currentPassword').value;
        const newPassword = document.getElementById('newPassword').value;
        const confirmPassword = document.getElementById('confirmPassword').value;
        
        if (newPassword || confirmPassword || currentPassword) {
            if (!currentPassword) {
                document.getElementById('currentPasswordError').textContent = 'Debes ingresar tu contraseña actual';
                document.getElementById('currentPasswordError').style.display = 'block';
                isValid = false;
            }
            
            if (newPassword.length > 0 && newPassword.length < 8) {
                document.getElementById('passwordError').style.display = 'block';
                isValid = false;
            }
            
            if (newPassword !== confirmPassword) {
                document.getElementById('confirmPasswordError').style.display = 'block';
                isValid = false;
            }
        }
        
        return isValid;
    }
    
    // Enviar formulario
    updateForm.addEventListener('submit', function(e) {
        e.preventDefault();
        
        // Ocultar alertas previas
        successAlert.style.display = 'none';
        errorAlert.style.display = 'none';
        
        if (validateForm()) {
            // Simular envío al servidor
            setTimeout(() => {
                showSuccess('Tus datos se han actualizado correctamente');
                
                // Aquí iría la lógica AJAX para enviar los datos
                console.log('Datos enviados:', {
                    fotoPerfil: profilePictureInput.files[0] || null,
                    nombres: document.getElementById('nombres').value.trim(),
                    apellidos: document.getElementById('apellidos').value.trim(),
                    documento: document.getElementById('documento').value.trim(),
                    email: document.getElementById('email').value.trim(),
                    telefono: document.getElementById('telefono').value.trim(),
                    currentPassword: document.getElementById('currentPassword').value,
                    newPassword: document.getElementById('newPassword').value
                });
            }, 1000);
        }
    });
    
    // Cancelar cambios
    cancelBtn.addEventListener('click', function() {
        if (confirm('¿Estás seguro de que deseas descartar los cambios?')) {
            loadUserData();
            // Limpiar campos de contraseña
            document.getElementById('currentPassword').value = '';
            document.getElementById('newPassword').value = '';
            document.getElementById('confirmPassword').value = '';
            strengthBar.style.width = '0%';
            strengthLabel.textContent = 'Seguridad: baja';
            strengthLabel.style.color = '';
        }
    });
    
    // Inicializar
    loadUserData();
});


/* ================================= */
/* ========== HEADER BASE ========== */
/* ================================= */

header.encabezado {
  background: white;
  border-bottom: 1px solid #ccc;
  padding: 1rem 2rem;
  position: fixed;
  top: 0;
  width: 100%;
  z-index: 999;
  font-family: 'Georgia', serif;
}

/* FLEX GENERAL */
.contenedor-header {
  max-width: 1300px;
  margin: 0 auto;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

/* MENÚ IZQUIERDO */
.nav-izquierda {
  display: flex;
  gap: 2rem;
}

.nav-izquierda a {
  text-decoration: none;
  color: #000;
  font-size: 0.85rem;
  letter-spacing: 0.05rem;
  text-transform: uppercase;
  position: relative;
  transition: color 0.3s ease;
}

/* LÍNEAS ANIMADAS EN HOVER */
.nav-izquierda a::before,
.nav-izquierda a::after {
  content: "";
  position: absolute;
  width: 100%;
  height: 2px;
  background: linear-gradient(to right, #0b6b10, #15ad3b); /* verde degradado */
  transform: scaleX(0);
  transition: transform 0.3s ease;
  left: 0;
}

/* Línea superior */
.nav-izquierda a::before {
  top: -6px;
  transform-origin: left;
}

/* Línea inferior */
.nav-izquierda a::after {
  bottom: -6px;
  transform-origin: right;
}

/* Hover: activa las líneas y cambia color */
.nav-izquierda a:hover::before,
.nav-izquierda a:hover::after {
  transform: scaleX(1);
}
.nav-izquierda a:hover {
  color: #0a6e22;
}

/* Estado activo permanente */
.nav-izquierda a.activo {
  color: #0a6e22;
}
.nav-izquierda a.activo::before,
.nav-izquierda a.activo::after {
  transform: scaleX(1);
}


/* LOGO CENTRADO */
.logo-centro img {
  height: 70px;
  object-fit: contain;
}

/* MENÚ DERECHO */
.menu-derecha {
  display: flex;
  align-items: center;
  gap: 1.5rem;
}
.icono {
  width: 24px;
  height: 24px;
  object-fit: contain;
  display: inline-block;
  vertical-align: middle;
  cursor: pointer;
}

/* MENÚ USUARIO DESPLEGABLE */
.perfil-wrapper {
  position: relative;
}
.menu-usuario {
  display: none;
  flex-direction: column;
  position: absolute;
  top: 140%;
  right: 0;
  background-color: white;
  border: 1px solid #ccc;
  box-shadow: 0 4px 8px rgba(0,0,0,0.1);
  border-radius: 5px;
  padding: 0.5rem 1rem;
  z-index: 1000;
}
.menu-usuario a {
  text-decoration: none;
  color: #333;
  padding: 0.4rem 0;
  font-size: 0.9rem;
}
.menu-usuario a:hover {
  color: #001e61;
}
.menu-usuario.activo {
  display: flex;
}
