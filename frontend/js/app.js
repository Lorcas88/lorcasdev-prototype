import { addToCart, updateBadge, fetchServices } from './utils.js'
import { loadNavbar, loadFooter } from './layout.js'

const cardTemplate = (data) => {
  return `
    <div class="col">
      <article class="card h-100" id="service-card-${data.id}">
        <img src=${data.img} class="card-img-top" />
        <div class="card-body">
          <h5 class="card-title">${data.title}</h5>
          <p class="card-text">${data.description}</p>
          <div class="d-flex justify-content-center gap-4">
            <a href="product.html?id=${data.id}" class="btn btn-primary btn-add"
              >Ver detalle</a
            >
          </div>
        </div>
      </article>
    </div>
  `
}

function render(container, services) {
  const cardsHTML = services.map(cardTemplate).join('')
  container.innerHTML = cardsHTML
}

async function initMain() {
  const services = await fetchServices()

  const cardsContainer = document.getElementById('cards_container')

  render(cardsContainer, services)
  updateBadge()
}

async function init() {
  await loadNavbar()
  await loadFooter()
  initMain()
}

init()
