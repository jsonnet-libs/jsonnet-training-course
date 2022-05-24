var heading = document.querySelector('h1')

//create anchor
var anchor = document.createElement('a');
anchor.className = 'anchor-link';
anchor.innerHTML = '☰';
anchor.style.cursor = 'pointer';

var toc = document.createElement('div');
toc.id = 'toc';
toc.style.display = 'none';

toc.addEventListener('mouseleave', e => {
    toc.style.display = 'none';
})
anchor.addEventListener('click', e => {
    toc.style.display = 'block';
})

document.querySelectorAll('h2, h3, h4, h5, h6').forEach($heading => {
    var level = $heading.nodeName.charAt(1);
    var current = toc;
    var ul
    var li;
    for (i=1; i<level; i++) {
      ul = current.querySelector('ul:last-child');
      if (ul == null) {
        ul = document.createElement('ul');
        current.appendChild(ul);
      } else {
        li = ul.querySelector('li:last-child');
      }
      current = li
    }

    var li = document.createElement('li');
    ul.appendChild(li)

    var headerId = $heading.id
    var a = document.createElement('a');
    a.href = '#' + headerId;
    var h = $heading;
    a.innerHTML = $heading.innerHTML;
    a.querySelectorAll('a').forEach($child => {
      a.removeChild($child);
    });
    li.appendChild(a)
})

if (document.querySelectorAll('h2, h3, h4, h5, h6').length > 0) {
    //prepend anchor before heading text
    var text = heading.innerText;
    heading.innerText = "";
    heading.appendChild(anchor);
    heading.append(text);

    toc.style.position = 'absolute';
    toc.style.top = anchor.offsetTop + 'px';
    toc.style.left = anchor.offsetLeft + 'px';

    document.querySelector('body').appendChild(toc);
}
