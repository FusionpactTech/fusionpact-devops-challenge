# Use nginx:alpine for lightweight serving
FROM nginx:alpine

# Remove default nginx website
RUN rm -rf /usr/share/nginx/html/*

# Copy HTML file to nginx html directory
COPY Devops_Intern.html /usr/share/nginx/html/index.html

# Copy nginx configuration if needed (optional)
# COPY nginx.conf /etc/nginx/nginx.conf

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
