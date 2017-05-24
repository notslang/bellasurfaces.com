document.addEventListener('DOMContentLoaded', function() {
  var controller, i, j, k, label, len, radio, ref, ref1, results, slidebox, sliderId, totalSlides;
  sliderId = 0;
  ref = document.getElementsByTagName('x-slidebox');
  for (j = 0, len = ref.length; j < len; j++) {
    slidebox = ref[j]
    setupController(slidebox, sliderId)
    sliderId++
  }
});

setupController = function (slidebox, sliderId) {
  totalSlides = slidebox.querySelectorAll("x-slides > x-slide").length;
  controller = document.createElement('controller');
  for (i = k = 0, ref1 = totalSlides; 0 <= ref1 ? k < ref1 : k > ref1; i = 0 <= ref1 ? ++k : --k) {
    radio = document.createElement('input');
    radio.setAttribute('type', 'radio');
    radio.setAttribute('name', sliderId);
    radio.setAttribute('id', "slider-" + sliderId + "-" + i);
    radio.setAttribute('value', i);
    if (i === 0) {
      radio.checked = true
    }
    radio.onclick = function() {
      return this.parentNode.parentNode.slideTo(this.value);
    };
    label = document.createElement('label');
    label.setAttribute('for', "slider-" + sliderId + "-" + i);
    controller.appendChild(radio);
    controller.appendChild(label);
  }
  slidebox.appendChild(controller);
  setInterval(function (){
    slidebox.slideNext()
    selected = slidebox.querySelector('[selected]')
    selectedIndex = Array.prototype.indexOf.call(
      selected.parentElement.children, selected
    )
    document.getElementById("slider-" + sliderId + "-" + selectedIndex).checked = true
  }, 5000)
}
