// Source: https://attacomsian.com/blog/deep-anchor-links-javascript
document.querySelectorAll('h1, h2, h3, h4, h5, h6').forEach($heading => {
    //create id from heading text
    var id = $heading.getAttribute("id") || $heading.innerText.toLowerCase().replace(/[`~!@#$%^&*()_|+\-=?;:'",.<>\{\}\[\]\\\/]/gi, '').replace(/ +/g, '-');

    //add id to heading
    $heading.setAttribute('id', id);

    //append parent class to heading
    $heading.classList.add('anchor-heading');

    //create anchor
    $anchor = document.createElement('a');
    $anchor.className = 'anchor-link';
    $anchor.href = '#' + id;
    $anchor.innerHTML = '☍';

    //append anchor after heading text
    $heading.appendChild($anchor);
});
