# Dockerfile.frontend
# Use the official Nginx image as the base image
FROM nginx:alpine

# Remove the default Nginx index.html
RUN rm /usr/share/nginx/html/index.html

# Copy the static HTML file to the Nginx default public directory
COPY Devops_Intern.html /usr/share/nginx/html/index.html

# Expose the port Nginx runs on
EXPOSE 80

# Nginx starts automatically as defined in its base image
CMD ["nginx", "-g", "daemon off;"]