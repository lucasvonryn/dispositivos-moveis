/// <reference path="../pb_data/types.d.ts" />

migrate((app) => {
  const users = app.findCollectionByNameOrId("users")
  const password = users.fields.getByName("password")
  password.min = 6

  users.listRule = "@request.auth.id != ''"
  users.viewRule = "@request.auth.id != ''"
  users.createRule = ""
  users.updateRule = "id = @request.auth.id"
  users.deleteRule = "id = @request.auth.id"
  app.save(users)

  const solicitacoes = new Collection({
    type: "base",
    name: "solicitacoes",
    listRule: "@request.auth.id != ''",
    viewRule: "@request.auth.id != ''",
    createRule: "@request.auth.id != '' && @request.body.usuario = @request.auth.id",
    updateRule: "@request.auth.id != '' && usuario = @request.auth.id",
    deleteRule: "@request.auth.id != '' && usuario = @request.auth.id",
    fields: [
      {
        name: "titulo",
        type: "text",
        required: true,
        min: 1,
        max: 120,
      },
      {
        name: "descricao",
        type: "text",
        required: true,
        min: 1,
        max: 5000,
      },
      {
        name: "foto",
        type: "file",
        required: true,
        maxSelect: 1,
        maxSize: 5242880,
        mimeTypes: [
          "image/jpeg",
          "image/png",
          "image/webp",
          "image/heic",
          "image/heif",
        ],
      },
      {
        name: "usuario",
        type: "relation",
        required: true,
        collectionId: users.id,
        maxSelect: 1,
        cascadeDelete: false,
      },
      {
        name: "nomeUsuario",
        type: "text",
        required: true,
        min: 1,
        max: 120,
      },
      {
        name: "latitude",
        type: "number",
        required: true,
      },
      {
        name: "longitude",
        type: "number",
        required: true,
      },
    ],
  })
  app.save(solicitacoes)

  const comentarios = new Collection({
    type: "base",
    name: "comentarios",
    listRule: "@request.auth.id != ''",
    viewRule: "@request.auth.id != ''",
    createRule: "@request.auth.id != '' && @request.body.usuario = @request.auth.id",
    updateRule: null,
    deleteRule: null,
    fields: [
      {
        name: "texto",
        type: "text",
        required: true,
        min: 1,
        max: 2000,
      },
      {
        name: "solicitacao",
        type: "relation",
        required: true,
        collectionId: solicitacoes.id,
        maxSelect: 1,
        cascadeDelete: true,
      },
      {
        name: "usuario",
        type: "relation",
        required: true,
        collectionId: users.id,
        maxSelect: 1,
        cascadeDelete: false,
      },
      {
        name: "nomeUsuario",
        type: "text",
        required: true,
        min: 1,
        max: 120,
      },
    ],
  })
  app.save(comentarios)

  const contas = [
    { nome: "Ewelin Komechen", email: "ewelin@utfpr.edu.br" },
    { nome: "Lucas Von Ryn", email: "lucas@utfpr.edu.br" },
  ]

  for (const conta of contas) {
    const record = new Record(users)
    record.set("name", conta.nome)
    record.set("email", conta.email)
    record.set("emailVisibility", true)
    record.setVerified(true)
    record.setPassword("123456")
    app.save(record)
  }
}, (app) => {
  const comentarios = app.findCollectionByNameOrId("comentarios")
  app.delete(comentarios)

  const solicitacoes = app.findCollectionByNameOrId("solicitacoes")
  app.delete(solicitacoes)

  try {
    const ewelin = app.findAuthRecordByEmail("users", "ewelin@utfpr.edu.br")
    app.delete(ewelin)
  } catch (_) {}

  try {
    const lucas = app.findAuthRecordByEmail("users", "lucas@utfpr.edu.br")
    app.delete(lucas)
  } catch (_) {}
})
