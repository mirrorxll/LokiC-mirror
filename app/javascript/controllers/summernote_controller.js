import { Controller } from 'stimulus'

require('summernote/dist/summernote-bs4.css');
require('summernote/dist/summernote-bs4.js');
require('codemirror/lib/codemirror.css');
require('codemirror/lib/codemirror.js');
require('codemirror/mode/xml/xml.js');
require('codemirror/theme/monokai.css');

export default class extends Controller {
    static targets = []

    initialize(){
        $.ajax({
            url: 'https://api.github.com/emojis',
            // async: true
        }).then(function(data) {
            window.emojis = Object.keys(data);
            window.emojiUrls = data;
        })
    }

    connect(){
        $('[data-editor="summernote"]').summernote({
            height: 300,
            focus: true,
            prettifyHtml: true,
            placeholder: 'Write here...',
            toolbar: [
                ['style', ['style']],
                ['font', ['bold', 'underline', 'clear']],
                ['fontname', ['fontname']],
                ['height', ['height']],
                ['color', ['color']],
                ['para', ['ul', 'ol', 'paragraph']],
                ['table', ['table']],
                ['insert', ['link', 'picture', 'video']],
                ['view', ['fullscreen', 'codeview', 'help']]
            ]
        });

        if ($('.note-editor.note-frame.card').length > 1) {
            $('[data-controller="summernote"]').first().children().last().remove()
        }

        function sendFile(file, toSummernote){
            console.log('called sendFile().');
            let data = new FormData();
            data.append('upload[image]', file);
            $.ajax({
                data: data,
                type: 'POST',
                url: '/summernote_uploads.json',
                cache: false,
                contentType: false,
                processData: false,
                success: function(data){
                    console.log("image url: ", data.url);
                    console.log('successfully created.');
                    let img = document.createElement("IMG");
                    img.src = data.url;
                    img.setAttribute('id', data.upload_id);
                    toSummernote.summernote("insertNode", img)
                }
            })
        }
        function deleteFile(file_id){
            $.ajax({
                type: 'DELETE',
                url: `/summernote_uploads/${file_id}`,
                cache: false,
                contentType: false,
                processData: false
            })
        }
    }
}