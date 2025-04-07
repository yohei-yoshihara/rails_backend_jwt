require 'rails_helper'

RSpec.describe "/tasks", type: :request do

  describe "GET /index" do
    it "renders a successful response" do
      user = User.create(username: "user", password: "password")
      post "/api/v1/signin", params: {username: user.username, password: user.password}, as: :json
      token = JSON.parse(response.body).deep_symbolize_keys[:token]
      
      task = Task.create(title: "task1", description: "this is task1", completed: false)
      get "/api/v1/tasks", headers: {"Authorization": "Bearer #{token}"}, as: :json
      expect(response).to be_successful

      resp_tasks = JSON.parse(response.body)
      expect(resp_tasks.count).to eq(1)

      resp_task = resp_tasks[0].deep_symbolize_keys
      expect(resp_task[:title]).to eq(task.title)
      expect(resp_task[:description]).to eq(task.description)
      expect(resp_task[:completed]).to eq(task.completed)
    end

    it "no token" do
      task = Task.create(title: "task1", description: "this is task1", completed: false)
      get "/api/v1/tasks", headers: {}, as: :json
      expect(response.status).to eq(401)
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      user = User.create(username: "user", password: "password")
      post "/api/v1/signin", params: {username: user.username, password: user.password}, as: :json
      token = JSON.parse(response.body).deep_symbolize_keys[:token]

      task = Task.create(title: "task1", description: "this is task1", completed: false)
      get "/api/v1/tasks/#{task.id}", headers: {"Authorization": "Bearer #{token}"}, as: :json
      expect(response).to be_successful

      resp_task = JSON.parse(response.body).deep_symbolize_keys
      expect(resp_task[:title]).to eq(task.title)
      expect(resp_task[:description]).to eq(task.description)
      expect(resp_task[:completed]).to eq(task.completed)
    end

    it "no token" do
      task = Task.create(title: "task1", description: "this is task1", completed: false)
      get "/api/v1/tasks/#{task.id}", headers: {}, as: :json
      expect(response.status).to eq(401)
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Task" do
        user = User.create(username: "user", password: "password")
        post "/api/v1/signin", params: {username: user.username, password: user.password}, as: :json
        token = JSON.parse(response.body).deep_symbolize_keys[:token]

        task_attrs = {
          title: "task1",
          description: "this is task1",
          completed: false
        }
        post "/api/v1/tasks", headers: {"Authorization": "Bearer #{token}"}, params: task_attrs, as: :json
        expect(response.status).to eq(201)

        resp_task = JSON.parse(response.body).deep_symbolize_keys
        expect(resp_task[:title]).to eq(task_attrs[:title])
        expect(resp_task[:description]).to eq(task_attrs[:description])
        expect(resp_task[:completed]).to eq(task_attrs[:completed])
      end
    end

    context "with invalid parameters" do
      it "creates a new Task" do
        user = User.create(username: "user", password: "password")
        post "/api/v1/signin", params: {username: user.username, password: user.password}, as: :json
        token = JSON.parse(response.body).deep_symbolize_keys[:token]

        task_attrs = {
          title: "",
          description: "",
          completed: false
        }
        post "/api/v1/tasks", headers: {"Authorization": "Bearer #{token}"}, params: task_attrs, as: :json
        expect(response.status).to eq(422)
        json = JSON.parse(response.body).deep_symbolize_keys
        expect(json[:title][0]).to eq("can't be blank")
        expect(json[:description][0]).to eq("can't be blank")
      end
    end

    context "no token" do
      it "creates a new Task" do
        task_attrs = {
          title: "task1",
          description: "this is task1",
          completed: false
        }
        post "/api/v1/tasks", headers: {}, params: task_attrs, as: :json
        expect(response.status).to eq(401)
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      it "updates the requested task" do
        user = User.create(username: "user", password: "password")
        post "/api/v1/signin", params: {username: user.username, password: user.password}, as: :json
        token = JSON.parse(response.body).deep_symbolize_keys[:token]

        task = Task.create(title: "task1", description: "this is task1", completed: false)

        task_attrs = {
          title: "task2",
          description: "this is task2",
          completed: true
        }
        patch "/api/v1/tasks/#{task.id}", headers: {"Authorization": "Bearer #{token}"}, params: task_attrs, as: :json
        expect(response.status).to eq(200)

        resp_task = JSON.parse(response.body).deep_symbolize_keys
        expect(resp_task[:title]).to eq(task_attrs[:title])
        expect(resp_task[:description]).to eq(task_attrs[:description])
        expect(resp_task[:completed]).to eq(task_attrs[:completed])
      end
    end

    context "with invalid parameters" do
      it "updates the requested task" do
        user = User.create(username: "user", password: "password")
        post "/api/v1/signin", params: {username: user.username, password: user.password}, as: :json
        token = JSON.parse(response.body).deep_symbolize_keys[:token]

        task = Task.create(title: "task1", description: "this is task1", completed: false)

        task_attrs = {
          title: "",
          description: "",
          completed: true
        }
        patch "/api/v1/tasks/#{task.id}", headers: {"Authorization": "Bearer #{token}"}, params: task_attrs, as: :json
        expect(response.status).to eq(422)

        json = JSON.parse(response.body).deep_symbolize_keys
        expect(json[:title][0]).to eq("can't be blank")
        expect(json[:description][0]).to eq("can't be blank")
      end
    end

    context "no token" do
      it "updates the requested task" do
        task = Task.create(title: "task1", description: "this is task1", completed: false)

        task_attrs = {
          title: "",
          description: "",
          completed: true
        }
        patch "/api/v1/tasks/#{task.id}", headers: {}, params: task_attrs, as: :json
        expect(response.status).to eq(401)
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested task" do
      user = User.create(username: "user", password: "password")
      post "/api/v1/signin", params: {username: user.username, password: user.password}, as: :json
      token = JSON.parse(response.body).deep_symbolize_keys[:token]

      task = Task.create(title: "task1", description: "this is task1", completed: false)

      delete "/api/v1/tasks/#{task.id}", headers: {"Authorization": "Bearer #{token}"}, as: :json
      expect(response.status).to eq(204)

      expect(Task.count).to eq(0)
    end

    it "no token" do
      task = Task.create(title: "task1", description: "this is task1", completed: false)

      delete "/api/v1/tasks/#{task.id}", headers: {}, as: :json
      expect(response.status).to eq(401)

      expect(Task.count).to eq(1)
    end
  end
end
