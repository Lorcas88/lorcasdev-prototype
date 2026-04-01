export function formatCLP(value) {
  return new Intl.NumberFormat('es-CL', {
    style: 'currency',
    currency: 'CLP',
  }).format(value)
}

export function saveCart(cart) {
  localStorage.setItem('cart', JSON.stringify(cart))
}

export function getCart() {
  return JSON.parse(localStorage.getItem('cart')) || []
}

export function addToCart(id, data) {
  const cart = getCart()

  const indexService = data.findIndex((s) => s.id === id)
  if (indexService !== -1) {
    // Retrieves the index if the service was already clicked.
    // This is to update the amount on the cart object.
    // If the index searched not exist, returns -1. If not
    // it will create tje object on the cart
    const index = cart.findIndex((c) => c.id === id)
    if (index !== -1) {
      cart[index].amount += 1
    } else {
      cart.push({
        id: data[indexService].id,
        name: data[indexService].title,
        price: data[indexService].price,
        amount: 1,
      })
    }
  }

  saveCart(cart)
  updateBadge()
}

export function updateBadge() {
  const cartBadge = document.querySelector('.nav-item .badge')

  const cart = getCart()

  const amountsList = cart.map((service) => service.amount)
  const totalCart = amountsList.reduce((accumulator, current) => {
    return accumulator + current
  }, 0)

  cartBadge.innerHTML = totalCart
}

// This functions was created to emulate the fetch to a real DB
export async function fetchServices() {
  const url = '/data/data.json'

  try {
    const response = await fetch(url)
    if (!response.ok) {
      throw new Error(`Response status: ${response.status}`)
    }

    const result = await response.json()
    // services = result.services
    return result.services
  } catch (error) {
    console.error(error.message)
  }
}
