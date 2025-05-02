document.addEventListener('DOMContentLoaded', function() {
    // Elementos del DOM
    const filtroFecha = document.getElementById('filtro-fecha');
    const filtroEstado = document.getElementById('filtro-estado');
    const sinResultados = document.getElementById('sin-resultados');
    const personalizacionesContainer = document.getElementById('personalizaciones-container');
    const modalDetalles = document.getElementById('modalDetalles');
    const cerrarModal = document.querySelector('.cerrar-modal');
    const contenidoDetalles = document.getElementById('contenido-detalles');
    
    // Datos de ejemplo (en un sistema real, estos vendrían de una API)
    const personalizaciones = [
      {
        id: 'P-001',
        fecha: '15/01/2025',
        estado: 'completado',
        imagen: '../imagenes/personalizaciones/anillo-1.jpg',
        nombre: 'Anillo de compromiso con esmeralda',
        especificaciones: {
          material: 'Oro blanco 18k',
          piedraPrincipal: 'Esmeralda colombiana (1.2 ct)',
          piedrasSecundarias: 'Diamantes (0.5 ct total)',
          talla: '6.5',
          precio: '$2,500,000',
          fechaEntrega: '20/02/2025'
        },
        detallesAdicionales: 'Anillo personalizado con esmeralda central y diamantes en el aro. Diseño inspirado en la colección Selva.'
      },
      {
        id: 'P-002',
        fecha: '10/12/2024',
        estado: 'en-proceso',
        imagen: '../imagenes/personalizaciones/anillo-2.jpg',
        nombre: 'Anillo de compromiso clásico',
        especificaciones: {
          material: 'Oro amarillo 14k',
          piedraPrincipal: 'Diamante (0.8 ct)',
          piedrasSecundarias: 'Diamantes (0.3 ct total)',
          talla: '7.0',
          precio: '$3,200,000',
          fechaEntrega: '15/01/2025'
        },
        detallesAdicionales: 'Diseño clásico de corte solitario con diamante central y pequeños diamantes en el aro. Elaborado a mano por nuestros artesanos.'
      }
    ];
    
    // Función para mostrar/ocultar el mensaje de "sin resultados"
    function verificarResultados() {
      const tarjetasVisibles = document.querySelectorAll('.tarjeta-personalizacion:not(.oculto)').length;
      
      if (tarjetasVisibles === 0) {
        sinResultados.style.display = 'block';
        personalizacionesContainer.style.display = 'none';
      } else {
        sinResultados.style.display = 'none';
        personalizacionesContainer.style.display = 'block';
      }
    }
    
    // Función para aplicar filtros
    function aplicarFiltros() {
      const fechaSeleccionada = filtroFecha.value;
      const estadoSeleccionado = filtroEstado.value;
      
      document.querySelectorAll('.tarjeta-personalizacion').forEach(tarjeta => {
        let coincideFecha = true;
        let coincideEstado = true;
        
        // Filtro por estado
        if (estadoSeleccionado !== 'todos') {
          const estadoTarjeta = tarjeta.querySelector('.estado').classList[1];
          coincideEstado = estadoTarjeta === estadoSeleccionado;
        }
        
        // Aquí iría la lógica para filtrar por fecha (simplificada para el ejemplo)
        if (fechaSeleccionada !== 'todos') {
          // En un sistema real, compararías las fechas reales
          coincideFecha = true; // Simplificación para el ejemplo
        }
        
        if (coincideFecha && coincideEstado) {
          tarjeta.classList.remove('oculto');
        } else {
          tarjeta.classList.add('oculto');
        }
      });
      
      verificarResultados();
    }
    
    // Función para mostrar detalles en el modal
    function mostrarDetalles(idPersonalizacion) {
      const personalizacion = personalizaciones.find(p => p.id === idPersonalizacion);
      
      if (personalizacion) {
        contenidoDetalles.innerHTML = `
          <h2>${personalizacion.nombre}</h2>
          <div class="detalle-contenido">
            <div class="imagen-detalle">
              <img src="${personalizacion.imagen}" alt="${personalizacion.nombre}">
            </div>
            <div class="info-detalle">
              <h3>Especificaciones</h3>
              <ul>
                <li><strong>Fecha:</strong> ${personalizacion.fecha}</li>
                <li><strong>Estado:</strong> <span class="estado ${personalizacion.estado}">${personalizacion.estado === 'completado' ? 'Completado' : 'En proceso'}</span></li>
                ${Object.entries(personalizacion.especificaciones).map(([key, value]) => `
                  <li><strong>${key.charAt(0).toUpperCase() + key.slice(1).replace(/([A-Z])/g, ' $1')}:</strong> ${value}</li>
                `).join('')}
              </ul>
              
              <h3>Detalles adicionales</h3>
              <p>${personalizacion.detallesAdicionales}</p>
            </div>
          </div>
        `;
        
        modalDetalles.style.display = 'flex';
      }
    }
    
    // Event listeners
    filtroFecha.addEventListener('change', aplicarFiltros);
    filtroEstado.addEventListener('change', aplicarFiltros);
    
    cerrarModal.addEventListener('click', function() {
      modalDetalles.style.display = 'none';
    });
    
    window.addEventListener('click', function(event) {
      if (event.target === modalDetalles) {
        modalDetalles.style.display = 'none';
      }
    });
    
    // Delegación de eventos para los botones "Ver detalles"
    document.addEventListener('click', function(event) {
      if (event.target.closest('.ver-detalle')) {
        const tarjeta = event.target.closest('.tarjeta-personalizacion');
        const id = tarjeta.dataset.id; // En un sistema real, usarías un ID real
        mostrarDetalles(id || 'P-001'); // Usamos P-001 como fallback para el ejemplo
      }
      
      if (event.target.closest('.reutilizar')) {
        // Aquí iría la lógica para reutilizar el diseño
        alert('Funcionalidad de reutilizar diseño en desarrollo');
      }
    });
    
    // Verificar resultados al cargar la página
    verificarResultados();
  });