// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//

//= require jquery
//= require jquery-migrate-1.2.1.min
//= require bootstrap.min
//= require jquery-ui-1.10.3.custom.min
//= require jquery.knob.modified.min
//= require jquery.flot.min
//= require jquery.flot.pie.min
//= require jquery.flot.stack.min
//= require jquery.flot.resize.min
//= require jquery.flot.time.min
//= require jquery.sparkline.min
//= require fullcalendar.min
//= require jquery.gritter.min
//= require core.min
//= require jquery.noty.min
//= require default.min
//= require index
//= require turbolinks
//= require home
//= stub jquery-2.0.3.min
//= stub jquery-1.10.2.min




$(document).ready(function () {

  var id = params['id'];
//  $('#fitness_partial').load('/home/fitness?id=' + id);
//  $('#diet_partial').load('/home/diet?id=' + id);
//  $('#medication_partial').load('/home/medication?id=' + id);
//  $('#targets_partial').load('/home/targets?id=' + id);
//  $('#upcoming_patients_partial').load('/home/dashboard');
//  $.get('/home/flot_charts?id=' + id);


$(document).ajaxStart(function () {
    $("#loading").show();
}).ajaxStop(function () {
    $("#loading").hide();
});

});