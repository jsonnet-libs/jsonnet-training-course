window.addEventListener('load', e => {
    document.querySelectorAll('pre').forEach($pre => {
      $pre.className='prettyprint linenums';
    });
    PR.prettyPrint();
});
