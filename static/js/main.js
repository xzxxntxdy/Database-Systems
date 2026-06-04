// 通用 AJAX 错误处理
$(document).ajaxError(function(event, xhr, settings, error) {
    console.error('AJAX Error:', error, settings.url);
});
