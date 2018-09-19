/*jshint browser: true, nomen: false, eqnull: true, es5:true, trailing:true */

(function () {
  "use strict";
  var work_form = $("form[data-behavior='work-form']"),
      Autocomplete = require('hyrax/autocomplete'),
      LinkedData = require('hyrax/autocomplete/linked_data');

  function patch_autocomplete() {
    var method = Autocomplete.prototype.setup;
    if (!window._autocomplete_patched) {
      Autocomplete.prototype.setup = function (element, fieldName, url) {
        // defer to original method for relevant BasicMetadata fields:
        var defer = ['based_near', 'language', 'work'],
            autourl = element.attr('data-autocomplete-url'),
            declared = (element.attr('data-autocomplete') === fieldName),
            ld = (declared && autourl && autourl.indexOf('authorities') !== -1),
            additionalField = element.context === undefined;
        if (additionalField || (ld && defer.indexOf(fieldName) == -1)) {
          new LinkedData(element, url);
          console.log('Using patched autocomplete for field', fieldName);
        } else {
          method(element, fieldName, url);
        }
      };
      window._autocomplete_patched = true;
    }
  }

  if (work_form.length && work_form.attr('id').indexOf('newspaper_') != -1) {
    patch_autocomplete();
  }
}());
