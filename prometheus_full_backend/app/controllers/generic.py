from flask import Blueprint, request, jsonify
from ..db import db
from .. import models

def model_by_name(name:str):
    return getattr(models, name)

def to_dict(obj):
    data = {}
    for c in obj.__table__.columns:
        v = getattr(obj, c.name)
        try:
            data[c.name] = v.isoformat()
        except AttributeError:
            data[c.name] = v
    return data

def make_blueprint(model_name:str):
    M = model_by_name(model_name)
    bp = Blueprint(model_name.lower(), __name__)
    pk_cols = [c.name for c in M.__table__.primary_key.columns]

    @bp.get('/')
    def list_items():
        return jsonify([to_dict(i) for i in M.query.all()])

    @bp.post('/')
    def create_item():
        data = request.get_json() or {}
        obj = M(**data)
        db.session.add(obj)
        db.session.commit()
        return jsonify(to_dict(obj)), 201

    if len(pk_cols) == 1:
        @bp.get('/<int:item_id>')
        def get_item(item_id):
            obj = db.get_or_404(M, item_id)
            return jsonify(to_dict(obj))

        @bp.put('/<int:item_id>')
        def update_item(item_id):
            obj = db.get_or_404(M, item_id)
            data = request.get_json() or {}
            for k, v in data.items():
                if hasattr(obj, k):
                    setattr(obj, k, v)
            db.session.commit()
            return jsonify(to_dict(obj))

        @bp.delete('/<int:item_id>')
        def delete_item(item_id):
            obj = db.get_or_404(M, item_id)
            db.session.delete(obj)
            db.session.commit()
            return ('', 204)
    else:
        # Composite PK via /pk?col1=..&col2=..
        @bp.get('/pk')
        def get_item_pk():
            filt = {k: request.args.get(k, type=int) for k in pk_cols}
            obj = M.query.filter_by(**filt).first()
            if not obj: return jsonify({"error":"not found"}), 404
            return jsonify(to_dict(obj))

        @bp.put('/pk')
        def update_item_pk():
            filt = {k: request.args.get(k, type=int) for k in pk_cols}
            obj = M.query.filter_by(**filt).first()
            if not obj: return jsonify({"error":"not found"}), 404
            data = request.get_json() or {}
            for k, v in data.items():
                if hasattr(obj, k): setattr(obj, k, v)
            db.session.commit()
            return jsonify(to_dict(obj))

        @bp.delete('/pk')
        def delete_item_pk():
            filt = {k: request.args.get(k, type=int) for k in pk_cols}
            obj = M.query.filter_by(**filt).first()
            if not obj: return jsonify({"error":"not found"}), 404
            db.session.delete(obj)
            db.session.commit()
            return ('', 204)

    return bp
