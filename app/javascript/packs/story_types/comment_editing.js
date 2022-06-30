$(document).on('show.bs.collapse', ('#commentForm'), function() {
    $('textarea#story_type_comment').froalaEditor({
        key: 'KfdolbcqsaA2wzA-13==',
        editorClass: 'border rounded p-2',
        toolbarInline: true,
        toolbarButtons: ['undo', 'redo', '|', 'bold', 'italic', 'underline', 'strikeThrough', '|', 'color', 'lineHeight', '|', 'paragraphFormat', 'align', 'formatOL', 'formatUL', 'insertLink', 'insertImage'],
        imageUploadURL: '/images/upload',
        imageUploadMethod: 'POST',
        toolbarVisibleWithoutSelection: false,
        zIndex: 3333,
        heightMin: 100,
        placeholderText: 'Type here....'
    })
});
