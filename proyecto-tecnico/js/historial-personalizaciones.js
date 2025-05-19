document.addEventListener('DOMContentLoaded', () => {
  const filtroFecha = document.getElementById('filtro-fecha');
  const filtroEstado = document.getElementById('filtro-estado');
  const sinResultados = document.getElementById('sin-resultados');
  const personalizacionesContainer = document.getElementById('personalizaciones-container');
  const modalDetalles = document.getElementById('modalDetalles');
  const cerrarModal = document.querySelector('.cerrar-modal');
  const contenidoDetalles = document.getElementById('contenido-detalles');

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

  function verificarResultados() {
    const visibles = document.querySelectorAll('.tarjeta-personalizacion:not(.oculto)').length;
    const hayResultados = visibles > 0;

    sinResultados.style.display = hayResultados ? 'none' : 'block';
    personalizacionesContainer.style.display = hayResultados ? 'block' : 'none';
  }

  function aplicarFiltros() {
    const estado = filtroEstado.value;
    const fecha = filtroFecha.value;

    document.querySelectorAll('.tarjeta-personalizacion').forEach(tarjeta => {
      const estadoTarjeta = tarjeta.querySelector('.estado').classList[1];
      const coincideEstado = estado === 'todos' || estado === estadoTarjeta;
      const coincideFecha = true; // Por ahora, siempre verdadero

      tarjeta.classList.toggle('oculto', !(coincideEstado && coincideFecha));
    });

    verificarResultados();
  }

  function mostrarDetalles(id) {
    const item = personalizaciones.find(p => p.id === id);
    if (!item) return;

    const especificacionesHTML = Object.entries(item.especificaciones).map(([key, value]) => {
      const label = key.charAt(0).toUpperCase() + key.slice(1).replace(/([A-Z])/g, ' $1');
      return `<li><strong>${label}:</strong> ${value}</li>`;
    }).join('');

    contenidoDetalles.innerHTML = `
      <h2>${item.nombre}</h2>
      <div class="detalle-contenido">
        <div class="imagen-detalle">
          <img src="${item.imagen}" alt="${item.nombre}">
        </div>
        <div class="info-detalle">
          <h3>Especificaciones</h3>
          <ul>
            <li><strong>Fecha:</strong> ${item.fecha}</li>
            <li><strong>Estado:</strong> <span class="estado ${item.estado}">${item.estado === 'completado' ? 'Completado' : 'En proceso'}</span></li>
            ${especificacionesHTML}
          </ul>
          <h3>Detalles adicionales</h3>
          <p>${item.detallesAdicionales}</p>
        </div>
      </div>
    `;

    modalDetalles.style.display = 'flex';
  }

  filtroFecha.addEventListener('change', aplicarFiltros);
  filtroEstado.addEventListener('change', aplicarFiltros);

  cerrarModal.addEventListener('click', () => modalDetalles.style.display = 'none');

  window.addEventListener('click', e => {
    if (e.target === modalDetalles) modalDetalles.style.display = 'none';
  });

  document.addEventListener('click', e => {
    const btnDetalle = e.target.closest('.ver-detalle');
    const btnReutilizar = e.target.closest('.reutilizar');

    if (btnDetalle) {
      const tarjeta = btnDetalle.closest('.tarjeta-personalizacion');
      mostrarDetalles(tarjeta?.dataset.id || 'P-001');
    }

    if (btnReutilizar) {
      alert('Funcionalidad de reutilizar diseño en desarrollo');
    }
  });

  verificarResultados();
});
