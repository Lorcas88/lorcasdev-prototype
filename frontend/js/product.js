import { formatCLP, addToCart, updateBadge, fetchServices } from './utils.js'
import { loadNavbar, loadFooter } from './layout.js'

const productTemplate = (data) => {
  return `
    <div class="row g-4 align-items-center">
      <div class="col-12 col-md-6">
        <img
          src=${data.img}
          alt="Vista previa del servicio"
          class="img-fluid rounded object-fit-cover w-100"
          id="product_image"
        />
      </div>

      <div class="col-12 col-md-6 text-start">
        <p class="text-info text-uppercase fw-semibold mb-2">
          Servicio destacado
        </p>
        <h1 class="mb-3" id="product_title">${data.title}</h1>
        <p class="fs-5 text-info mb-3" id="product_price">${formatCLP(data.price)}</p>
        <p class="mb-4" id="product_description">
          ${data.description}
        </p>

        <div class="d-flex flex-wrap gap-3 mb-4">
          <button
            class="btn btn-primary px-4"
            id="product_add_button"
            data-service-id=${data.id}
          >
            Agregar al carrito
          </button>
          <a href="shopping_cart.html" class="btn btn-outline-light px-4">
            Ver carrito
          </a>
        </div>

        <ul class="list-group list-group-flush rounded overflow-hidden">
          <li
            class="list-group-item bg-transparent text-light border-secondary"
          >
            Entrega estimada:
            <span id="product_delivery">${data.delivery}</span>
          </li>
          <li
            class="list-group-item bg-transparent text-light border-secondary"
          >
            Modalidad: <span id="product_mode">${data.mode}</span>
          </li>
          <li
            class="list-group-item bg-transparent text-light border-secondary"
          >
            Incluye soporte: <span id="product_support">${data.include_support}</span>
          </li>
        </ul>
      </div>
    </div>
  `
}

const featuresTemplate = (data) => {
  const featuresHTML = data.features
    .map(
      (feature) => `
        <div class="col">
          <div class="border border-secondary rounded p-3 h-100">
            <h3 class="h5 mb-2">${feature.title}</h3>
            <p class="mb-0">${feature.description}</p>
          </div>
        </div>
      `,
    )
    .join('')

  return featuresHTML
}

function getProductIdFromUrl() {
  const params = new URLSearchParams(window.location.search)
  return Number(params.get('id'))
}

function renderProduct(service) {
  const container = document.getElementById('product_detail')

  const productHTML = productTemplate(service)
  container.innerHTML = productHTML

  const containerFeatures = document.getElementById('product_features')
  const featuresHTML = featuresTemplate(service)
  containerFeatures.innerHTML = featuresHTML
}

async function initProductPage() {
  const services = await fetchServices()
  const productId = getProductIdFromUrl()

  const service = services.find((item) => item.id === productId)
  if (!service) return

  renderProduct(service)
  updateBadge()

  document
    .getElementById('product_add_button')
    .addEventListener('click', () => addToCart(productId, services))
}

async function init() {
  await loadNavbar()
  await loadFooter()
  initProductPage()
}

init()
