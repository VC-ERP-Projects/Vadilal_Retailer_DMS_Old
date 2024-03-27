$(function () {

    $('.slider-arrow').click(function (event) {

        if ($(this).hasClass('show')) {
            $(".slider-arrow, .right_panel").animate({
                right: "+=5%"
            }, 300, function () {
                // Animation complete.
            });
            $(this).html('<img src="Images/right_arrow.png"/>').removeClass('show').addClass('hide');
        }
        else {
            $(".slider-arrow, .right_panel").animate({
                right: "-=5%"
            }, 300, function () {
                // Animation complete.
            });
            $(this).html('<img src="Images/left_arrow.png"/>').removeClass('hide').addClass('show');
        }
        event.stopPropagation();
    });

    $('.left-slider-arrow').click(function (event) {

        if ($(this).hasClass('show')) {

            $('.left-slider-arrow').css('margin-left', '0%');
            $(".left-slider-arrow, .left_panel").animate({
                left: "-=27%"

            }, 700, function () {
                // Animation complete.
            });

            $(this).html('<img src="../Images/right_arrow.png"/>').removeClass('show').addClass('hide');


        }
        else {

            $('.left-slider-arrow').css('margin-left', '0%');
            $(".left-slider-arrow, .left_panel").animate({
                left: "+=27%"

            }, 700, function () {
                // Animation complete.
            });
            $(this).html('<img src="../Images/left_arrow.png"/>').removeClass('hide').addClass('show');
        }
        event.stopPropagation();
    });
});

function iswithoutminus(evt) {
    var charCode = (evt.which) ? evt.which : event.keyCode;
    if (charCode == 45)
        return false;
    else
        return true;
}

function isNumberKeyWithStar(evt) {
    var charCode = (evt.which) ? evt.which : event.keyCode;
    if (charCode > 31 && (charCode < 48 || charCode > 57) && charCode != 42)
        return false;
    return true;
}

function isNumberKey(evt) {
    var charCode = (evt.which) ? evt.which : event.keyCode;
    if (charCode > 31 && (charCode < 48 || charCode > 57))
        return false;
    return true;
}

function isNumberKeyWithMinus(evt) {
   // alert(txt.count('-'));
    var charCode = (evt.which) ? evt.which : event.keyCode;
    var vl = evt.target.value;
    //alert(vl.indexOf('-'));
    if (charCode == 45 || charCode == 46) {
        if (evt.target.value.search(/\./) > -1 && charCode == 46)
            return false;
        else if (evt.target.value.search(/\-/) > -1 && charCode == 45) {
            return false;
        } else
         return true;
    }
    else if (charCode > 31 && (charCode < 48 || charCode > 57))
            return false;
    
    return true;
}
function iswithoutminus(evt) {
    var charCode = (evt.which) ? evt.which : event.keyCode;
    if (charCode == 45)
        return false;
    else
    return true;
}
function isNumberKeyForAmount(evt) {
    var charCode = (evt.which) ? evt.which : event.keyCode;
    if (charCode > 31 && (charCode < 48 || charCode > 57) && charCode != 46)
        return false;
    return true;
}

function isNumberKeyMinusAmount(evt) {
    var charCode = (evt.which) ? evt.which : event.keyCode;
    if (charCode > 31 && (charCode < 45 || charCode > 57))
        return false;
    return true;
}

function isCharNumKey(evt) {
    var charCode = (evt.which) ? evt.which : event.keyCode;
    if (charCode == 8 || charCode == 31 || charCode == 32 || (charCode > 47 && charCode < 58) || (charCode > 64 && charCode < 91) || (charCode > 96 && charCode < 123))
        return true;
    return false;
}

function isContact(evt) {
    var charCode = (evt.which) ? evt.which : event.keyCode;
    if (charCode > 31 && (charCode < 48 || charCode > 57) && charCode != 43)
        return false;
    return true;
}

function isNumberKey0To5(evt) {
    var charCode = (evt.which) ? evt.which : event.keyCode;
    if (charCode > 31 && (charCode < 48 || charCode > 53))
        return false;
    return true;
}

function isCharNumDashKey(evt) {
    var charCode = (evt.which) ? evt.which : event.keyCode;
    if (charCode == 8 || charCode == 45 || (charCode > 47 && charCode < 58) || (charCode > 64 && charCode < 91) || (charCode > 96 && charCode < 123))
        return true;
    return false;
}

function checkAgree() {
    if ($('.rdbagree').is(":checked")) {
        return true;
    }
    else {
        ModelMsg('Please accept our terms and conditions', 3);
        return false;
    }

}

