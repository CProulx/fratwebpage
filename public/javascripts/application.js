// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function set_photo_order()
{
  $('album_photo_order').value=($('current_photos').childElements().collect(function(e){return e.id.gsub(/photo\_/,'')}))
}

function remove_photo(photo_id)
{
    if($('current_photos').childElements().length == 1 )
        alert("You cannot remove the last photo in an album");
    else
        if(confirm("Are you sure you want to remove this photo from the album?"))
            document.getElementById("photo_"+photo_id).remove();
            set_photo_order();
        end
    end
}