document.addEventListener('sopasjs-ready', () => {
  const page_1 = document.querySelector('div.sopasjs-ui-navbar-wrapper > div > ul > li:nth-child(3) > a > i');
  page_1.classList.remove('fa-file');
  page_1.classList.add('fa-video-camera');

  const page_2 = document.querySelector('div.sopasjs-ui-navbar-wrapper > div > ul > li:nth-child(4) > a > i');
  page_2.classList.remove('fa-file');
  page_2.classList.add('fa-eye');

  const page_3 = document.querySelector('div.sopasjs-ui-navbar-wrapper > div > ul > li:nth-child(5) > a > i');
  page_3.classList.remove('fa-file');
  page_3.classList.add('fa-list-ul');

  const page_FirstLabel = document.querySelector('div.sopasjs-ui-navbar-wrapper > div > ul > li:nth-child(2)');
  const page_App = document.querySelector('div.sopasjs-ui-navbar-wrapper > div > ul > li:nth-child(6)');
  const page_Setup = document.querySelector('div.sopasjs-ui-navbar-wrapper > div > ul > li:nth-child(7) > a');

  page_FirstLabel.remove();
  page_App.remove();
  page_Setup.remove();

  setTimeout(() => {
    const element = document.querySelector("div.sjs-wrapper > div > div.sjs-fullscreen-toggle")
    if(element) {
      element.parentElement.removeChild(element)
    }
    document.title = 'CSK_Module_MultiRemoteCamera'
  }, 500);
})