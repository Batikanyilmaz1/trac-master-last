var SidebarMenuEffects = (function() {

    function hasParentClass(e, classname) {
        if (e === document) return false;
        if (classie.has(e, classname)) {
            return true;
        }
        return e.parentNode && hasParentClass(e.parentNode, classname);
    }

    function mobilecheck() {
        var check = false;
        (function(a) {
            if(/(android|ipad|playbook|silk|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows (ce|phone)|xda|xiino/i.test(a.substr(0,4)))check = true;
        })(navigator.userAgent || navigator.vendor || window.opera);
        return check;
    }

    function init() {
        var container = document.getElementById('st-container'),
            buttons = Array.prototype.slice.call(document.querySelectorAll('#st-trigger-effects > button')),
            eventtype = mobilecheck() ? 'touchstart' : 'click';

        buttons.forEach(function(el, i) {
            var effect = el.getAttribute('data-effect');

            el.addEventListener(eventtype, function(ev) {
                ev.stopPropagation();
                ev.preventDefault();

                // Toggle menu open/close
                if (container.classList.contains('st-menu-open')) {
                    closeMenu(container);
                } else {
                    openMenu(container, effect);
                }
            });
        });

        // Close the menu if the user clicks outside of it
        document.addEventListener(eventtype, function(ev) {
            if (!hasParentClass(ev.target, 'st-menu') && !hasParentClass(ev.target, 'btn_menu')) {
                closeMenu(container);
            }
        });

        function openMenu(container, effect) {
            container.className = 'st-container'; // clear existing classes
            container.classList.add(effect);
            setTimeout(function() {
                container.classList.add('st-menu-open');
            }, 25);
        }

        function closeMenu(container) {
            container.classList.remove('st-menu-open');
            // Remove any effect classes here if necessary
            container.className = 'st-container';
        }
    }

    init();

})();
