AGN.Lib.DomInitializer.new('mailing-content-overview', function($elem, $scope) {
  if (!$scope) {
    var data = AGN.Lib.Storage.get('mailings-content-dynNameID');
    if (data) {
      var $tr = $("tr[data-dyn-name-id='" + data.dynNameID + "']");
      if ($tr.exists()) {
        var top = $tr.position().top;
        setTimeout(function () {
          $("body").scrollTop(top);
        }, 1);
        AGN.Lib.Storage.set('mailings-content-dynNameID', {dynNameID: 0});
      }
    }
  }

  var $datePicker = $('#myDatePicker');
  if ($datePicker.exists()) {
    $datePicker.pickadate('picker')
      .on({
        set: function(thingSet) {
          if ('select' in thingSet) {
            var d = new Date(thingSet.select);
            $('#startDay').val(d.getDate());
            $('#startMonth').val(d.getMonth() + 1);
            $('#startYear').val(d.getFullYear());
          } else {
            $('#startDay').val(0);
            $('#startMonth').val(0);
            $('#startYear').val(0);
          }
        }
      });

    var $timePicker = $('#myTimePicker');

    $timePicker.on('timepicker:complete', function() {
      var time = $timePicker.val();

      $('#startHour').val(time.substr(0, 2));
      $('#startMinute').val(time.substring(3, 5));
    });

    $timePicker.on('timepicker:incomplete', function() {
      $('#startHour').val(0);
      $('#startMinute').val(0);
    });
  }
});
