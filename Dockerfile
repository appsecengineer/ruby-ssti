# Dockerfile
FROM ruby:2.7

# Set the working directory
WORKDIR /app

# Copy the Gemfile and Gemfile.lock into the image
COPY Gemfile Gemfile.lock /app/

# Install dependencies
RUN bundle install

# Copy the application code
COPY . /app/

# Expose port 8880
EXPOSE 8880

# Run the application on port 8880
CMD ["ruby", "app.rb", "-o", "0.0.0.0", "-p", "8880"]

