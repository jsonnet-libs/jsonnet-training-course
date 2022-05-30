window.addEventListener('load', e => {
    var heading = document.querySelector('h1');

    //create anchor
    var anchor = document.createElement('a');
    anchor.className = 'anchor-link';
    anchor.innerHTML = '☰';
    anchor.style.cursor = 'pointer';

    var toc = document.createElement('nav');
    toc.id = 'toc';
    toc.style.display = 'none';

    toc.addEventListener('mouseleave', e => {
        toc.style.display = 'none';
    })
    anchor.addEventListener('click', e => {
        toc.style.display = 'block';
    })

    var lastLevel = 1;
    var lastId = 'null';
    var li = toc;
    var ul;
    document.querySelectorAll('h2, h3, h4, h5, h6').forEach($heading => {
        var level = $heading.nodeName.charAt(1);

        if (level > lastLevel) {
            ul = li.querySelector('ul.'+lastId)
            if (ul == null) {
                ul = document.createElement('ul');
                ul.classList.add($heading.id);
                li.appendChild(ul);
            }
        }

        if (level < lastLevel) {
                console.log($heading.id)
            for (i=lastLevel; i>level; i--) {
                ul = li.parentNode.parentNode.parentNode;
                console.log(ul)
                if (ul == null) {
                    ul = toc.querySelector('ul:last-child')
                    break
                }
                li = ul.querySelector('li:last-child').parentNode.parentNode;
            }
        }

        li = document.createElement('li');
        ul.appendChild(li);

        var headerId = $heading.id;
        var a = document.createElement('a');
        a.href = '#' + headerId;
        var h = $heading;
        a.innerHTML = $heading.innerHTML;
        a.querySelectorAll('a').forEach($child => {
          a.removeChild($child);
        });
        li.appendChild(a);
        lastLevel = level;
        lastId = headerId;
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
});
