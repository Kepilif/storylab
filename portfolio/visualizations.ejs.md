```{=html}
<div class="sl-viz-grid list">
<% for (const item of items) { const external = item.url.startsWith('https://'); %>
  <article class="sl-viz-card" <%= metadataAttrs(item) %>>
    <a class="sl-viz-preview" href="<%- item.url %>" <% if (external) { %>target="_blank" rel="noopener noreferrer"<% } %>>
      <img src="<%- item.thumbnail %>" alt="<%- item.alt %>" loading="lazy" decoding="async" referrerpolicy="no-referrer" width="640" height="420">
    </a>
    <div class="sl-viz-body">
      <p class="sl-eyebrow listing-categories"><%- item.categories.join(' · ') %></p>
      <h2 class="listing-title"><%- item.title %></h2>
      <div class="sl-viz-tags"><span class="listing-tool"><%- item.tool %></span><span class="listing-mode"><%- item.mode %></span></div>
      <p class="sl-viz-chart listing-chart"><%- item.chart %></p>
      <p class="listing-description"><%- item.description %></p>
      <div class="sl-viz-actions">
        <a class="sl-button" href="<%- item.url %>" <% if (external) { %>target="_blank" rel="noopener noreferrer"<% } %>><%= external ? 'Otwórz w Tableau ↗' : 'Otwórz wizualizacje →' %></a>
        <% if (item.related) { %><a class="sl-text-link" href="<%- item.related %>" <% if (item.related.startsWith('https://')) { %>target="_blank" rel="noopener noreferrer"<% } %>><%- item.related_label %> →</a><% } %>
      </div>
    </div>
  </article>
<% } %>
</div>
```
