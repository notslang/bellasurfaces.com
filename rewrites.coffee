redirects = {
  '/': []
  '/services': []
  '/about': [
    '/about-2'
  ]
  '/contact': []
  '/portfolio': []
  '/portfolio/granite-kitchen': [
    '/portfolio/bella-surfaces-granite-kitchen'
    '/bella-surfaces-granite-kitchen'
  ]
  '/portfolio/hutch-kitchen': [
    '/portfolio/bella-surfaces-hutch-kitchen'
    '/bella-surfaces-hutch-kitchen'
  ]
  '/portfolio/granite-dog-bowl': [
    '/portfolio/bella-surfaces-granite-dog-bowl'
    '/Bella Surfaces Granite Dog Bowl'
    '/bella-surfaces-granite-dog-bowl'
    '/portfolio/Bella Surfaces Granite Dog Bowl'
  ]
  '/portfolio/soap-stone-sink': [
    '/portfolio/bella-surfaces-granite'
    '/Bella Surfaces Granite'
    '/bella-surfaces-granite'
    '/portfolio/Bella Surfaces Granite'
  ]
  '/portfolio/sink-corner': [
    '/portfolio/bella-surfaces-sink-corner'
    '/Bella Surfaces Sink Corner'
    '/bella-surfaces-sink-corner'
    '/portfolio/Bella Surfaces Sink Corner'
  ]
  '/wp-content/plugins/contact-form-7': []
  '/wp-content/plugins/contact-form-7/includes': []
  '/wp-content/plugins/contact-form-7/includes/css': []
  '/wp-content/plugins/contact-form-7/includes/js': []
  '/wp-content/plugins/social-media-widget': []
  '/wp-content/plugins/social-media-widget/images': []
  '/wp-content/plugins/social-media-widget/images/default': []
  '/wp-content/plugins/social-media-widget/images/default/32': []
  '/wp-content/themes': []
  '/wp-content/themes/fluid': []
  '/wp-content/themes/fluid/css': []
  '/wp-content/themes/fluid/images': []
  '/wp-content/themes/fluid/js': []
  '/wp-content/uploads': []
  '/wp-content/uploads/2012': []
  '/wp-content/uploads/2012/05': []
  '/wp-includes': []
  '/wp-includes/js': []
  '/wp-includes/js/jquery': []
  '/wp-includes/js/jquery/ui': []
}

for canonicalUrl, redirectList of redirects
  if canonicalUrl[-1...] is '/'
    console.log "rewrite ^#{canonicalUrl}index.html?$ #{canonicalUrl} permanent;"
  else
    console.log "rewrite ^#{canonicalUrl}(?:/index.html?|.html?|/)$ #{canonicalUrl} permanent;"

  for url in redirectList
    fixedUrl = url.replace(/\s/g, '\\s')
    if url[-1...] is '/'
      console.log "rewrite ^#{fixedUrl}(?:index.html?)?$ #{canonicalUrl} permanent;"
    else
      console.log "rewrite ^#{fixedUrl}(?:/index.html?|.html?|/)?$ #{canonicalUrl} permanent;"
