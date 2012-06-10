$(document).ready(function(){ 
    $('div.quota').css('visibility','hidden');
    $('textarea#micropost_content').keyup(function(event){
        var target = $(event.target);
        var quota = 140 - parseInt(target.val().length);
        if(quota>0){ 
            $('div.quota label').text(quota + ((quota>1)?' characters left':' character left'));
            $('div.quota').css('visibility','visible');
        }
        else {
            $('div.quota label').text('0 characters left');
            target.val(target.val().substring(0, 140));
        }
        
    })
});