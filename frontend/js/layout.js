export async function loadNavbar() {
  const response = await fetch('./components/navbar.html')
  const navbarHtml = await response.text()

  const header = document.querySelector('header')

  header.innerHTML = navbarHtml
}

export async function loadFooter() {
  const response = await fetch('./components/footer.html')
  const footerHtml = await response.text()

  const footer = document.querySelector('footer')

  footer.innerHTML = footerHtml
}
