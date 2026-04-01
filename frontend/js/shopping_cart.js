import { formatCLP, getCart, saveCart, updateBadge } from './utils.js'
import { loadNavbar, loadFooter } from './layout.js'

function renderCart() {
  const cart = getCart()

  const cartItems = document.getElementById('cart_items')

  if (cart.length === 0) {
    cartItems.innerHTML = `
      <tr>
        <td colspan="5" class="text-center text-secondary py-5">
          Tu carrito aun no tiene servicios agregados.
        </td>
      </tr>
    `
    renderSummary(cart)
    updateBadge()
    return
  }

  cartItems.innerHTML = cart
    .map((item) => {
      const subtotal = item.price * item.amount

      return `
        <tr>
          <td>${item.name}</td>
          <td>${formatCLP(item.price)}</td>
          <td>${item.amount}</td>
          <td>${formatCLP(subtotal)}</td>
          <td class="text-end">
            <button
              class="btn btn-sm btn-outline-danger"
              data-remove-id="${item.id}"
            >
              Quitar
            </button>
          </td>
        </tr>
      `
    })
    .join('')

  renderSummary(cart)
  updateBadge()
}

function renderSummary(cart) {
  const items = cart.reduce((acc, item) => acc + item.amount, 0)
  const subtotal = cart.reduce((acc, item) => acc + item.price * item.amount, 0)
  const fee = subtotal > 0 ? subtotal * 0.25 : 0
  const total = subtotal + fee

  document.getElementById('summary_items').textContent = items
  document.getElementById('summary_subtotal').textContent =
    `${formatCLP(subtotal)}`
  document.getElementById('summary_fee').textContent = `${formatCLP(fee)}`
  document.getElementById('summary_total').textContent = `${formatCLP(total)}`
}

function removeItem(id) {
  const cart = getCart().filter((item) => item.id !== id)
  saveCart(cart)
  renderCart()
}

function clearCart() {
  saveCart([])
  renderCart()
}

function bindEvents() {
  document.getElementById('cart_items').addEventListener('click', (e) => {
    if (e.target.matches('[data-remove-id]')) {
      const id = Number(e.target.dataset.removeId)
      removeItem(id)
    }
  })

  document
    .getElementById('clear_cart_button')
    .addEventListener('click', clearCart)

  document.getElementById('checkout_button').addEventListener('click', () => {
    alert('Solicitud enviada correctamente')
  })
}

function initCartPage() {
  renderCart()
  bindEvents()
}

async function init() {
  await loadNavbar()
  await loadFooter()
  initCartPage()
}

init()
