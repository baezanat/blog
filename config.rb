require "lib/path_helpers"
require "lib/image_helpers"

page '/*.xml', layout: false
page '/*.json', layout: false
page '/*.txt', layout: false

set :url_root, ENV.fetch('BASE_URL')

ignore '/templates/*'

LOCALES = ENV['LANGS'].split(",").map(&:to_sym)
activate :i18n, langs: LOCALES, mount_at_root: LOCALES[0]

activate :asset_hash
activate :directory_indexes
activate :pagination
activate :inline_svg

activate :dato, token: ENV.fetch('DATO_API_TOKEN'), live_reload: true

# set timezone
require 'tzinfo'
Time.zone = 'Europe/Rome'

webpack_command =
  if build?
    "yarn run build"
  else
    "yarn run dev"
  end

activate :external_pipeline,
  name: :webpack,
  command: webpack_command,
  source: ".tmp/dist",
  latency: 1

activate :blog do |blog|
  # This will add a prefix to all links, template references and source paths
  # blog.prefix = "blog"
  # blog.permalink = "{year}/{month}/{day}/{title}.html"
  # Matcher for blog source files
  # blog.sources = "{year}-{month}-{day}-{title}.html"
  # blog.taglink = "tags/{tag}.html"
  # blog.layout = "layout"
  # blog.summary_separator = /(READMORE)/
  # blog.summary_length = 250
  # blog.year_link = "{year}.html"
  # blog.month_link = "{year}/{month}.html"
  # blog.day_link = "{year}/{month}/{day}.html"
  # blog.default_extension = ".md"
  # blog.tag_template = "tag.html"
  # blog.calendar_template = "calendar.html"
  # Enable pagination
  # blog.paginate = true
  # blog.per_page = 10
  # blog.page_link = "page/{num}"
end

configure :build do
  activate :minify_html do |html|
    html.remove_input_attributes = false
  end
  activate :search_engine_sitemap,
    default_priority: 0.5,
    default_change_frequency: 'weekly'
end

configure :development do
  activate :livereload
end

helpers do
  include PathHelpers
  include ImageHelpers

  # Custom helper to theme
  def site_nav_menu
    [
      # dato.about_page,
      # dato.contact_page
    ]
  end

end

=begin
dato.tap do |dato|
  dato.articles.each do |article|
    proxy(
      '/articles/#{article.slug}.html',
      '/templates/article.html',
      locals: { article: article }
    )
  end
end
=end

=begin
paginate(
  dato.articles.sort_by(&:publication_date).reverse,
  '/article',
  '/templates/article.html'
  )
=end

#   MULTILANG SAMPLES
#
#   langs.each do |locale|
#     I18n.with_locale(locale) do
#       proxy "/#{locale}/index.html",
#         "/localizable/index.html",
#         locals: { page: dato.homepage },
#         locale: locale
#
#       proxy "/#{locale}/#{dato.about_page.slug}/index.html",
#         "/templates/about_page.html",
#         locals: { page: dato.about_page },
#         locale: locale
#
#       dato.aritcles.each do |article|
#         I18n.locale = locale
#         proxy "/#{locale}/articles/#{article.slug}/index.html", "/templates/article_template.html", :locals => { article: article }, ignore: true, locale: locale
#       end
#     end
#   end

#   langs.each do |locale|
#     I18n.with_locale(locale) do
#       I18n.locale = locale
#       paginate dato.articles.select{|a| a.published == true}.sort_by(&:date).reverse, "/#{I18n.locale}/articles", "/templates/articles.html", locals: { locale: I18n.locale }
#     end
#   end
# end

all_articles = dato.articles.sort_by(&:publication_date)
proxy "/index.html", "/templates/index.html", locals: { articles: all_articles }

dato.articles.each do |article|
  proxy "/articles/#{article.slug}.html",
    "/templates/article.html",
    locals: { article: article }
end

=begin
dato.tap do |dato|
  dato.articles.each do |article|
    proxy(
      "/articles/#{article.slug}.html",
      "/templates/article.html",
      locals: { article: article },
      ignore: true
    )
  end
end
=end

=begin
LOCALES.each do |locale|
  I18n.with_locale(locale) do
    prefix = locale == LOCALES[0] ? "" : "/#{locale}"

    proxy "#{prefix}/index.html",
      "/localizable/index.html",
      locale: locale

    proxy "#{prefix}/contact/index.html",
      "templates/contact_page.html",
      locals: { locale: I18n.locale },
      locale: locale
  end
end
=end

proxy "site.webmanifest",
  "templates/site.webmanifest",
  :layout => false

proxy "browserconfig.xml",
  "templates/browserconfig.xml",
  :layout => false

proxy "/_redirects",
  "/templates/redirects.txt",
  :layout => false

# all_articles = dato.articles.sort_by(&:publication_date)
# proxy "/index.html", "/templates/index.html", locals: { articles: all_articles }
