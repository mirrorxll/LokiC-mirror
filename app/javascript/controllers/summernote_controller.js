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
    }
}
