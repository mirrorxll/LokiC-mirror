require('summernote/dist/summernote-bs4.js');
require('summernote/dist/summernote-bs4.css');
require('summernote/dist/lang/summernote-ko-KR.min.js');
require('codemirror/lib/codemirror.js');
require('codemirror/lib/codemirror.css');
require('codemirror/mode/xml/xml.js');
require('codemirror/theme/monokai.css');

localStorage.setItem('summernoteSettings', JSON.stringify({
    height: 700,
    fontSizes: ['8', '9', '10', '11', '12', '14', '18', '24', '30', '36', '48', '60', '72', '96'],
    lineHeights: ['0.2', '0.3', '0.4', '0.5', '0.6', '0.8', '1.0', '1.2', '1.4', '1.5', '2.0', '3.0'],
    toolbar: [
        ['style', ['style']],
        ['font', ['bold', 'underline', 'clear']],
        ['fontname', ['fontname']],
        ['fontsize', ['fontsize']],
        ['color', ['color']],
        ['para', ['ul', 'ol', 'paragraph']],
        ['height', ['height']],
        ['table', ['table']],
        ['insert', ['link', 'picture', 'video']],
        ['view', ['fullscreen', 'codeview', 'help']],
    ]
}));
